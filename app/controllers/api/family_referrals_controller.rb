module Api
    class FamilyReferralsController < Api::ApplicationController
      include ApplicationHelper
      load_and_authorize_resource
  
      def compare
        render json: find_family_in_organization
      end
  
      def find_family_in_organization
        if params[:org] == 'external referral'
          { text: 'create referral' }
        else
          current_org = Organization.current.short_name
          Organization.switch_to params[:org]
          slug = "#{current_org}-#{params[:familyId]}"
          referrals = FamilyReferral.where(slug: slug)
          if referrals.any?
            referral = referrals.last
            if referral.saved?
              { text: 'already exist' }
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
  