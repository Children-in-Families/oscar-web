module Api
  class ReferralSourcesController < Api::ApplicationController
    include ApplicationHelper
    load_and_authorize_resource

    def get_referral_sources
      referral_sources = ReferralSource.find_by(id: params[:ref_category_id]).children
      render json: referral_sources
    end

    def referral_source_category
      referral_source_category = ReferralSource.find_by(id: params[:ref_source_id]).parent
      render json: referral_source_category
    end

    def get_all_referral_sources
      referral_sources = ReferralSource.child_referrals
      render json: referral_sources
    end
  end
end
