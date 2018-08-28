module Api
  class ClientsController < AdminController

    def compare
      render json: find_client_in_organization
    end

    def check_task
      render json: check_incomplete_task
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

    def check_incomplete_task
      name  = params['removedUser'].squish.split(' ')
      user  = User.find_by(first_name: name.first, last_name: name.last)
      tasks = user.tasks.where(completed: false, client_id: 894)
      if tasks.any?
        { text: 'incompleted tasks remain' }
      else
        { text: 'no task' }
      end
    end
  end
end
