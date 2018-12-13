class Location
    attr_accessor :city_id

    def self.from_city_id(city_id)
      location = Location.new
      location.city_id = city_id
      return location
    end
  end