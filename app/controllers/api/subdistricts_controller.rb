module Api
  class SubdistrictsController < Api::ApplicationController
    def index
      subdistricts = District.find(params[:district_id]).subdistricts
      render json: subdistricts
    end
  end
end
