module Api
  module V1
    class ClientsController < AdminController
      def index
        render json: Client.accessible_by(current_ability)
      end

      def compare
        render json: find_client_in_organization
      end

      private

      def find_client_by(params)
        if params[:first_name] && params[:gender] && params[:birth_province_id] && params[:date_of_birth]
          Client.filter(params)
        else
          []
        end
      end

      def find_client_in_organization
        found = []
        Organization.without_demo.each do |org|
          Organization.switch_to(org.short_name)
          client = find_client_by(params)
          inject_in_organization(client, org.full_name)
          found << client if client.present?
        end
        found.flatten
      end

      def inject_in_organization(collections, value)
        collections.each do |collection|
          collection.organization = value
        end
      end

    end
  end
end
