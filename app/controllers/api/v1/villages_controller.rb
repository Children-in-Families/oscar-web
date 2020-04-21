module Api
  module V1
    class VillagesController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Village.order(:name_en)
      end
    end
  end
end
