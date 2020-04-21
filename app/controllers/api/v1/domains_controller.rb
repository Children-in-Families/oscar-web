module Api
  module V1
    class DomainsController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Domain.all
      end
    end
  end
end
