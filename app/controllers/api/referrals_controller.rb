module Api
  class ReferralsController < AdminController
    def compare
      render json: find_client_in_organization
    end

    def find_client_in_organization
      text = nil

      if params[:org] == 'external referral'
        text = { text: 'create referral' }
      else
        Organization.switch_to params[:org]
        referrals = Referral.where(slug: params[:clientId])
        if referrals.any?
          referrals.each do |referral|
            if referral.saved?
              client = Client.find_by(slug: params[:clientId])
              text = client.status == 'Exited'? { text: 'exited client' } : { text: 'already exist' }
            else
              text = { text: 'already referred' }
            end
          end
        else
          text = { text: 'create referral' }
        end
        text
      end
    end

  end
end
