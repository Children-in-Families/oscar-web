module Api
  module V1
    class Clients::ReferralsController < Api::V1::BaseApiController
      before_action :find_client

      def index
        render json: @client.referrals.order(:name)
      end

      def create
        binding.pry
        referral = @client.referrals.new(referral_params)
        if referral.save
          @client.update_attributes(referred_external: true) if find_external_system(referral.referred_to)
          render json: referral
        else
          render json: referral.errors, status: :unprocessable_entity
        end
      end

      private

      def referral_params
        params.require(:referral).permit(:referred_to, :referred_from, :name_of_referee, :referee_id, :referral_phone, :referee_email, :date_of_referral, :referral_reason, :client_name, :slug, :ngo_name, :client_global_id, :level_of_risk, consent_form: [], service_ids: [])
      end
    end
  end
end
