module Api
  module V1
    class BaseApiController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      include ApplicationHelper

      before_action :authenticate_user!, if: :user_authenticated?
      before_action :doorkeeper_authorize!, if: :doorkeeper_controller?
      before_action :current_resource_owner
      before_filter :set_current_user

      private

      def current_resource_owner
        @current_user ||= if doorkeeper_token
                            User.find(doorkeeper_token.resource_owner_id)
                          else
                            current_user
                          end
      end

      def doorkeeper_controller?
        doorkeeper_token.present?
      end

      def user_authenticated?
        doorkeeper_token.nil?
      end

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
    end
  end
end
