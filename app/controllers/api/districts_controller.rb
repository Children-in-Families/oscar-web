module Api
  class DistrictsController < Api::ApplicationController
    def index
      data = Province.find(params[:province_id]).districts
      render json: { data: data }
    end
  end
end
