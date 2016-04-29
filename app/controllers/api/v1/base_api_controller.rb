module Api
  module V1
    class BaseApiController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!

      private

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:client_id])
      end
    end
  end
end
