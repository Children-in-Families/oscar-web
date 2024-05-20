module Api
  module V1
    class DevelopmentalMarkersController < Api::V1::BaseApiController
      def index
        markers = DevelopmentalMarker.all
        render json: markers
      end
    end
  end
end
