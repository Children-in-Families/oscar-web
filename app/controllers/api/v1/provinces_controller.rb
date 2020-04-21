module Api
  module V1
    class ProvincesController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Province.order(:name)
      end
    end
  end
end
