module Api
  module V2
    class VillagesController < Api::V1::BaseApiController
      def index
        render json: Village.order(:name_en)
      end
    end
  end
end
