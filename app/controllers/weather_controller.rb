require "climatology"

class WeatherController < ApplicationController
    def get
        city_id = params[:city_id]
        #c = Climatology::WeatherAPI.new('metric', 'e6c1499f69e96c245c88c36a9bf14dbf')
        location = Climatology::Location.from_city_id(city_id)
        weather_response = { city_id: city_id }
        p c.fetch([location])
        expect(true).to eq(true)
        render json: weather_response
    end
end



