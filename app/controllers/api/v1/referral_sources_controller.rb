module Api
  module V1
    class ReferralSourcesController < Api::V1::BaseApiController
      def index
        render json: ReferralSource.order(:name)
      end
    end
  end
end
