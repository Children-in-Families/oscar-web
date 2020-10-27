module Api
  module V1
    class Oauth2Controller < Api::V1::BaseApiController
      before_action :switch_to_public!
      before_action :authenticate_user!, if: :user_authenticated?
      before_action :doorkeeper_authorize!, if: :doorkeeper_controller?
      before_action :current_resource_owner

      respond_to :json

      private

        def current_resource_owner
          @current_user ||= if doorkeeper_token
                              User.find(doorkeeper_token.resource_owner_id)
                            else
                              current_user
                            end

        end

        def switch_to_public!
          Organization.switch_to 'public'
        end

        def doorkeeper_controller?
          doorkeeper_token.present?
        end

        def user_authenticated?
          doorkeeper_token.nil?
        end
    end
  end
end
