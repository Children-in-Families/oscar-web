module Api
  module V1
    class DistrictsController < Api::V1::BaseApiController

      def index
        render json: District.joins(:province).order('provinces.name').order(:name)
      end
    end
  end
end
