module Api
  class ClientsController < Api::ApplicationController

    def compare
      render json: find_client_in_organization
    end

    def render_client_statistics
      render json: client_statistics
    end

    def find_client_case_worker
      client = Client.find(params[:id])
      user_ids = client.users.non_strategic_overviewers.where.not(id: params[:user_id]).ids
      render json: { user_ids:  user_ids }
    end

    def assessments
      @assessments_count ||= client_assessments.count
      render json: { recordsTotal:  @assessments_count, recordsFiltered: @assessments_count, data: data }
    end

    private

    def find_client_in_organization
      results = []
      similar_fields = Client.find_shared_client(params)
      { similar_fields: similar_fields }
    end

    def client_statistics
      @csi_statistics = CsiStatistic.new($client_data).assessment_domain_score.to_json
      @enrollments_statistics = ActiveEnrollmentStatistic.new($client_data).statistic_data.to_json
      { text: "#{@csi_statistics} & #{@enrollments_statistics}" }
    end

    def data
      assessment_domain_hash = {}
      client_data = []
      assessment_data.each do |assessment|
        assessment_domain_hash = AssessmentDomain.where(assessment_id: assessment.id).pluck(:domain_id, :score).to_h if assessment.assessment_domains.present?
        domain_scores = domains.ids.map { |domain_id| assessment_domain_hash.present? ? ["domain_#{domain_id}", assessment_domain_hash[domain_id]] : ["domain_#{domain_id}", ''] }

        client_hash = { slug: assessment.client.slug,
          name: assessment.client.en_and_local_name,
          'assessment-number': assessment.client.assessments.count,
          date: assessment.created_at.strftime('%d %B %Y')
        }
        client_hash.merge!(domain_scores.to_h)
        client_data << client_hash
      end

      client_data
    end

    def assessment_data
      @assessments_data ||= fetch_assessments
    end

    def fetch_assessments
      # .select("assessments.id, clients.assessments_count as count, clients.id as client_id, clients.slug as client_slug, assessments.created_at as date")
      assessments = client_assessments.includes(:assessment_domains).order("#{sort_column} #{sort_direction}").references(:assessment_domains, :client)

      assessment_data = params[:length] != '-1' ? assessments.page(page).per(per_page) : assessments
    end

    def client_assessments
      @assessments ||= Assessment.joins(:client).where("assessments.default = ? AND assessments.client_id IN (?)", params[:default], $client_ids)
    end

    def domains
      @domains ||= params[:default] == 'true' ? Domain.csi_domains : Domain.custom_csi_domains
    end

    def page
      params[:start].to_i/per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      domains_fields = domains.map { |domain|  "assessment_domains.score" }
      columns = ["regexp_replace(clients.slug, '\\D*', '', 'g')::int", "clients.given_name", "clients.assessments_count", "assessments.created_at", *domains_fields]
      columns[params[:order]['0']['column'].to_i]
    end

    def sort_direction
      params[:order]['0']['dir'] == "desc" ? "desc" : "asc"
    end
  end
end
