module Api
  class ReferralSourcesController < Api::ApplicationController
    include ApplicationHelper
    load_and_authorize_resource

    def get_referral_sources
      binding.pry
      # referral_sources = ReferralSource.where(ancestry: params[:referral_source_category_id])
      render json: referral_source
    end
  end
end
