require "open_weather"
require "influxdb"
require "byebug"
require "time"

module Climatology
  class Error < StandardError; end
  # Your code goes here...

  # Remote Weather API fetcher
  class WeatherAPI
    def initialize(units, appid)
      @options = { units: units, APPID: appid }
    end

    def fetch(locations)
      responses = OpenWeather::Current.cities(
        locations.map(&:city_id), @options
      )
      responses["list"].map { |r| response_to_weather(r) }
    end

    def response_to_weather(response)
      Weather.from_values(response)
    end
  end

  class Weather
    attr_accessor :timestamp
    attr_accessor :values
    attr_accessor :location

    def self.from_db_values(db_values)
      values = JSON.parse(db_values["data"])
      weather = Weather.new
      if db_values.has_key?("time")
        weather.timestamp = Time.parse(db_values["time"])
      else
        weather.timestamp = Time.now
      end
      weather.values = values
      weather.location = Location.new
      weather.location.city_id = values["id"]
      return weather
    end

    def json_values
      JSON.dump(values)
    end

    def self.from_values(values)
      weather = Weather.new
      if values.has_key?("time")
        weather.timestamp = Time.parse(values["time"])
      else
        weather.timestamp = Time.now
      end
      weather.values = values
      weather.location = Location.new
      weather.location.city_id = values["id"]
      return weather
    end
  end

  class Location
    attr_accessor :city_id

    def self.from_city_id(city_id)
      location = Location.new
      location.city_id = city_id
      return location
    end
  end

  class DBHandler
    def initialize(params)
      params.merge!({
        host: "localhost",
        port: 8086
      })
      database = "weather"
      @client = InfluxDB::Client.new params
      @client.create_database(database)
      params[:database] = database
      @client = InfluxDB::Client.new params
    end

    def measurement_name(location)
      "current_weather_#{location.city_id}"
    end

    def insert(weather)
      data = {
        values: {
          data: weather.json_values
        }
      }
      @client.write_point(measurement_name(weather.location), data)
    end

    def obtain(location)
      query_str = "SELECT * FROM #{measurement_name(location)} ORDER BY time DESC LIMIT 1"
      @client.query query_str do |name, tags, points|
        points.each do |pt|
          return Weather.from_db_values(pt)
        end
      end
    end
  end
end