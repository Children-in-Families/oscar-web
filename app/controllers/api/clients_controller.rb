module Api
  class ClientsController < AdminController

    def compare
      render json: find_client_in_organization
    end

    private

    def find_client_in_organization
      results = []
      Organization.oscar.each do |org|
        Organization.switch_to(org.short_name)
        clients = find_client_by(params)
        set_organization_to_client(clients, org.full_name)
        results << clients if clients.any?
      end
      results.flatten
    end

    def find_client_by(params)
      if params[:given_name] || params[:birth_province_id] || params[:current_province_id] || params[:date_of_birth] || params[:local_given_name] || params[:local_family_name] || params[:family_name] || params[:commune] || params[:village]
        Client.filter(params)
      else
        []
      end
    end

    def set_organization_to_client(collections, value)
      collections.each do |collection|
        collection.organization = value
      end
    end
  end
end
