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
end