module Api
  module V1
    class Families::ExitNgosController < Api::V1::BaseApiController
      before_action :find_family

      def create
        exit_ngo = @family.exit_ngos.new(exit_ngo_params)
        if exit_ngo.save
          # send_reject_referral_family_email
          render json: @family
        else
          render json: @family.errors, status: :unprocessable_entity
        end
      end

      def update
        exit_ngo = @family.exit_ngos.find(params[:id])
        authorize exit_ngo
        if exit_ngo.update_attributes(exit_ngo_params)
          render json: @family
        else
          render json: @family.errors, status: :unprocessable_entity
        end
      end

      private

      def find_family
        @family = Family.accessible_by(current_ability).find(params[:family_id])
      end

      def exit_ngo_params
        remove_blank_exit_reasons
        params.require(:exit_ngo).permit(:exit_note, :exit_circumstance, :other_info_of_exit, :exit_date, exit_reasons: [])
      end

      def remove_blank_exit_reasons
        return if params[:exit_ngo][:exit_reasons].blank?
        params[:exit_ngo][:exit_reasons].reject!(&:blank?)
      end

      def send_reject_referral_family_email
        return unless @family.referrals.received.present? && @exit_ngo.exit_circumstance == 'Rejected Referral'
        referral = @family.referrals.received.last
        current_org = current_organization.full_name
        RejectReferralFamilyWorker.perform_async(current_user.name, current_org, referral.id)
      end
    end
  end
end
