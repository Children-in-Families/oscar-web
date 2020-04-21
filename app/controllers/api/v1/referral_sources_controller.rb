module Api
  module V1
    class ReferralSourcesController < Api::V1::BaseApiController

      def index
        render json: ReferralSource.order(:name)
      end

      def referral_source_parents
        ref_parents = ReferralSource.parent_categories
        render json: ref_parents
      end
    end
  end
end
