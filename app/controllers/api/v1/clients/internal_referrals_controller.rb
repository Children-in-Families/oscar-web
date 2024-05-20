module Api
  module V1
    class Clients::InternalReferralsController < Api::V1::BaseApiController
      include ReferralsConcern

      before_action :find_client
      before_action :set_internal_referral, only: [:show, :edit, :update, :destroy]

      def index
        @internal_referrals = @client.internal_referrals
        render json: @internal_referrals
      end

      def show
        render json: @internal_referral
      end

      def edit
        authorize @internal_referral, :edit?
      end

      def create
        @internal_referral = @client.internal_referrals.new(internal_referral_params)
        if @internal_referral.save
          render json: @internal_referral
        else
          render json: @internal_referral.errors, status: :unprocessable_entity
        end
      end

      def update
        if @internal_referral.update(internal_referral_params)
          render json: @internal_referral
        else
          render json: @internal_referral.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @internal_referral.destroy
        head :no_content
      end

      private

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:client_id]) if params[:client_id]
      end

      def set_internal_referral
        @internal_referral = @client.internal_referrals.find(params[:id])
      end

      def internal_referral_params
        params.require(:internal_referral).permit(:referral_date, :client_id, :user_id, :client_representing_problem, :emergency_note, :referral_reason, :crisis_management, :referral_decision, attachments: [], program_stream_ids: [])
      end
    end
  end
end
