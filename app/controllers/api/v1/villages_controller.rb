module Api
  module V1
    class VillagesController < Api::V1::BaseApiController
      def index
        render json: Village.order(:name_en)
      end
    end
  end
end
