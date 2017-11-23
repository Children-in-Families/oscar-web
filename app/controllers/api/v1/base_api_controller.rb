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
        unless request.headers['access-token'] == ENV['GOV_ACCESS_TOKEN'] && request.remote_ip == ENV['REMOTE_IP'] && request.headers['client'] == ENV['GOV_CLIENT'] && request.headers['uid'] == ENV['GOV_UID']
          authenticate_user!
        end
      end
    end
  end
end
