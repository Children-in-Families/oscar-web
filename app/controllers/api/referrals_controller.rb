module Api
  class ReferralsController < Api::ApplicationController
    include ApplicationHelper
    load_and_authorize_resource

    def compare
      render json: find_client_in_organization
    end

    def find_client_in_organization
      if params[:org] == 'external referral'
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
