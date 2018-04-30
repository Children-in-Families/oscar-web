module Api
  class SubdistrictsController < AdminController
    def index
      subdistricts = District.find(params[:district_id]).subdistricts
      render json: subdistricts
    end
  end
end
