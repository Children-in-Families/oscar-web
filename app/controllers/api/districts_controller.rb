module Api
  class DistrictsController < Api::ApplicationController
    def index
      if Organization.current.country == 'indonesia'
        data = City.find(params[:city_id]).districts
      else
        data = Province.find(params[:province_id]).districts
      end

      render json: { data: data }
    end
  end
end
