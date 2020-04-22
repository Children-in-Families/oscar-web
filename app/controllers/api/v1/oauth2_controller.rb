module Api
  module V1
    class Oauth2Controller < ActionController::Base
      protect_from_forgery with: :null_session, except: :index, if: proc { |c| c.request.format == 'application/json' }
      before_action :switch_to_public!
      before_action :authenticate_user!

      respond_to :json

      private

        # Doorkeeper methods
        def current_resource_owner
          User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end

        def switch_to_public!
          Organization.switch_to 'public'
        end
    end
  end
end
