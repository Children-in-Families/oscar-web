module Api
  class CitiesController < Api::ApplicationController
    def index
      data = Province.find(params[:province_id]).cities
      render json: { data: data }
    end
  end
end
