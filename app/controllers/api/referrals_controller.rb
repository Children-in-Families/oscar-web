module Api
  class ReferralsController < AdminController
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
            date_of_referral = referral.date_of_referral
            client = Client.find_by(slug: params[:clientId])
            client.status == 'Exited'? { text: "exited client", date: "#{date_of_referral}" } : { text: 'already exist' }
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
