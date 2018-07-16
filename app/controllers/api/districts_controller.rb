module Api
  class DistrictsController < AdminController
    def index
      data = Province.find(params[:province_id]).districts
      render json: { data: data }
    end
  end
end
