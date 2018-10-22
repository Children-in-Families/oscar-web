module Api
  class ClientsController < Api::ApplicationController

    def compare
      render json: find_client_in_organization
    end

    private

    def find_client_in_organization
      results = []
      shared_clients = Client.find_shared_client(params)
      Organization.oscar.each do |org|
        Organization.switch_to(org.short_name)
        slugs = shared_clients & Client.filter(params)
        results << org.full_name if slugs.any?
      end
      { organizations: results.flatten }
    end
  end
end
