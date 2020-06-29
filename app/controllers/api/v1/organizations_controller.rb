module Api
  module V1
    class OrganizationsController < Api::V1::BaseApiController
      skip_before_action :authenticate_user!, only: [:index, :create]
      before_action :authenticate_admin_user!, only: [:create]

      def index
        render json: Organization.visible.order(:created_at)
      end

      def clients
        bulk_clients = []
        Organization.only_integrated.pluck(:short_name).each do |short_name|
          Organization.switch_to short_name
          clients = JSON.parse ActiveModel::ArraySerializer.new(Client.limit(10).to_a, each_serializer: OrganizationClientSerializer).to_json
          bulk_clients << clients
        end
        Organization.switch_to 'public'

        render json: bulk_clients.flatten.compact, root: :data
      end

      def create
        if org = Organization.create_and_seed_generic_data(params.permit(:demo, :full_name, :short_name, :logo, supported_languages: []))
          render json: org, status: :ok
        else
          render json: { msg: org.errors }, status: :unprocessable_entity
        end
      rescue => e
        render json: e.message, status: :unprocessable_entity
      end

      private

      def authenticate_admin_user!
        authenticate_or_request_with_http_token do |token, _options|
          @current_user = AdminUser.find_by(token: token)
        end
      end
    end
  end
end
