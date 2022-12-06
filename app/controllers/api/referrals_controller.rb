module Api
  class ReferralsController < Api::ApplicationController
    include ApplicationHelper
    load_and_authorize_resource

    def compare
      render json: find_client_in_organization
    end

    def update
      referral = Referral.find(params[:id])
      if referral.update_attributes(params.require(:referral).permit(:referral_status))
        render json: { referral_status: referral.referral_status }, status: :ok
      else
        render json: referral.errors, status: :unprocessable_entity
      end
    end

    def find_client_in_organization
      if params[:org] == 'external referral' || params[:org] == 'external-referral' || params[:org] == 'mosvy-external-system'
        { text: 'create referral' }
      else
        Organization.switch_to params[:org]
        referrals = Referral.where(slug: params[:clientId])
        if referrals.any?
          referral = referrals.last
          if referral.saved?
            client = Client.find_by(slug: params[:clientId])
            date_of_reject = date_format(client.exit_ngos.last.try(:exit_date))
            client.exit_ngo? ? { text: "exited client", date: "#{date_of_reject}" } : { text: 'already exist' }
          else
            { text: 'already referred' }
          end
        else
          { text: 'create referral' }
        end

      end
    end

  end
end
