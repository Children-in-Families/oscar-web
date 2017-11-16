module Api
  module V1
    class BaseApiController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user_request

      private

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:client_id])
      end

      def authenticate_user_request
        unless request.headers['access-token'] == ENV['ACCESS_TOKEN'] && request.headers['request-from'] == ENV['REQUEST_FROM'] && request.headers['client'] == ENV['CLIENT'] && request.headers['uid'] == ENV['UID']
          authenticate_user!
        end
      end
    end
  end
end
