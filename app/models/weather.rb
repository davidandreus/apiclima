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