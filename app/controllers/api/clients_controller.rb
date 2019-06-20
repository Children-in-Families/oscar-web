module Api
  class ClientsController < Api::ApplicationController

    def compare
      render json: find_client_in_organization
    end

    def render_client_statistics
      render json: client_statistics
    end

    def assessments
      @assessments_count ||= Assessment.joins(:client).where(default: params[:default]).count
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
        assessment_domain_hash = assessment.assessment_domains.pluck(:domain_id, :score).to_h if assessment.assessment_domains.present?
        domain_scores = domains.ids.map { |domain_id| assessment_domain_hash.present? ? ["domain_#{domain_id}", assessment_domain_hash[domain_id]] : ["domain_#{domain_id}", ''] }
        client_hash = { slug: assessment.client.slug,
          name: assessment.client.en_and_local_name,
          'assessment-number': assessment.client.assessments.count, date: assessment.created_at.strftime('%d %B %Y')
        }
        client_hash.merge!(domain_scores.to_h)
        client_data << client_hash
      end
      client_data
    end

    def assessment_data
      @assessments ||= fetch_assessments
    end

    def fetch_assessments
      assessments = Assessment.includes(:assessment_domains, :client).where(assessments: { default: params[:default] }, client_id: params[:client_ids].split('/'))
      assessments = assessments.joins(:client).order("#{sort_column} #{sort_direction}")
      assessment_data = params[:length] != '-1' ? assessments.page(page).per(per_page) : assessments
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
