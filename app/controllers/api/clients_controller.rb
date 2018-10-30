module Api
  class ClientsController < Api::ApplicationController

    def compare
      render json: find_client_in_organization
    end

    def render_client_statistics
      render json: client_statistics
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

    def client_statistics
      @csi_statistics = CsiStatistic.new($client_data).assessment_domain_score.to_json
      @enrollments_statistics = ActiveEnrollmentStatistic.new($client_data).statistic_data.to_json
      { text: "#{@csi_statistics} & #{@enrollments_statistics}" }
    end
  end
end
