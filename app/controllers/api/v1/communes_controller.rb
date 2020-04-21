module Api
  module V1
    class CommunesController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Commune.order(:name_en)
      end
    end
  end
end
