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

  def measurement_name(location)
    "current_weather_#{location.city_id}"
  end
end