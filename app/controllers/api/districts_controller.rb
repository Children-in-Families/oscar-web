module Api
  class DistrictsController < AdminController
    def index
      districts = Province.find(params[:province_id]).districts
      render json: districts
    end
  end
end
