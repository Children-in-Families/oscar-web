module Api
  module V1
    class OrganizationsController < Api::V1::BaseApiController
      skip_before_action :authenticate_user!

      def index
        render json: Organization.visible.order(:created_at)
      end
    end
  end
end
