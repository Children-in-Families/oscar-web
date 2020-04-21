module Api
  module V1
    class DomainsController < Api::V1::BaseApiController

      def index
        render json: Domain.all
      end
    end
  end
end
