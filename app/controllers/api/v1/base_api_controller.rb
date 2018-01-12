module Api
  module V1
    class BaseApiController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user_request

      private

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:client_id])
      end

      def find_entity
        if params[:client_id].present?
          @custom_formable = Client.accessible_by(current_ability).friendly.find(params[:client_id])
        elsif params[:family_id].present?
          @custom_formable = Family.find(params[:family_id])
        elsif params[:partner_id].present?
          @custom_formable = Partner.find(params[:partner_id])
        elsif params[:user_id].present?
          @custom_formable = User.find(params[:user_id])
        end
      end

      def authenticate_user_request
        unless request.headers['access-token'] == ENV['GOV_ACCESS_TOKEN'] && request.headers['gov-domain'] == ENV['GOV_DOMAIN'] && request.headers['client'] == ENV['GOV_CLIENT'] && request.headers['uid'] == ENV['GOV_UID']
          authenticate_user!
        end
      end
    end
  end
end
