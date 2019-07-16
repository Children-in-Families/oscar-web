module Api
  module V2
    class CommunesController < Api::V1::BaseApiController
      def index
        render json: Commune.order(:name_en)
      end
    end
  end
end
