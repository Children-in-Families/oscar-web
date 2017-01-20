module Api
  module V1
    class ClientsController < Api::V1::BaseApiController
      def index
        render json: Client.accessible_by(current_ability)
      end
    end
  end
end
