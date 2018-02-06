module Api
  module V1
    class BaseApiController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!

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
    end
  end
end
