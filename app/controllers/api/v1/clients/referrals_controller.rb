module Api
  module V1
    class Clients::ReferralsController < Api::V1::BaseApiController
      include ReferralsConcern

      before_action :find_client
      before_action :find_referral, only: %I[show update destroy]

      def index
        render json: @client.referrals
      end

      def show
        render json: @referral
      end

      def create
        referral = @client.referrals.new(referral_params)
        if referral.save
          @client.update_attributes(referred_external: true) if find_external_system(referral.referred_to)
          render json: referral
        else
          render json: referral.errors, status: :unprocessable_entity
        end
      end

      def update
        if @referral.update_attributes(referral_params)
          render json: @referral
        else
          render json: @referral.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @referral.destroy
          head 204
        else
          render json: { error: 'Failed deleting custom field property' }
        end
      end

      private

      def referral_params
        params.require(:referral).permit(:referred_to, :referred_from, :name_of_referee, :referee_id, :referral_phone, :referee_email, :date_of_referral, :referral_reason, :client_name, :slug, :ngo_name, :client_global_id, :level_of_risk, consent_form: [], service_ids: [])
      end

      def find_referral
        if params[:client_id]
          @referral = @client.referrals.find(params[:id])
        else
          @referral = Referral.find(params[:id])
        end
      end
    end
  end
end
