module Api
  class ClientsController < Api::ApplicationController

    def compare
      render json: find_client_in_organization
    end

    def render_client_statistics
      render json: client_statistics
    end

    def assessments
      assessment_domain_hash = {}
      client_data = []
      # clients = Client.where(id: params[:client_ids].split('/'))
      domains = params[:default] == 'true' ? Domain.csi_domains.ids : Domain.custom_csi_domains.ids
      assessments = Assessment.includes(:assessment_domains, :client).where(assessments: { default: params[:default] }, client_id: params[:client_ids].split('/')).where.not(client_id: nil)
      assessments_count = assessments.count

      assessment_data = params[:length] != '-1' ? assessments.page(params[:draw]).per(params[:length]) : assessments
      assessment_data.each do |assessment|
        assessment_domain_hash = assessment.assessment_domains.pluck(:domain_id, :score).to_h if assessment.assessment_domains.present?
        domain_scores = domains.map { |domain_id| assessment_domain_hash.present? ? ["domain_#{domain_id}", assessment_domain_hash[domain_id]] : ["domain_#{domain_id}", ''] }
        client_hash = { slug: assessment.client.slug,
          name: assessment.client.en_and_local_name,
          'assessment-number': assessment.client.assessments.count, date: assessment.created_at.strftime('%d %B %Y')
        }
        client_hash.merge!(domain_scores.to_h)
        client_data << client_hash
      end

      render json: { recordsTotal:  assessments_count, recordsFiltered: assessments_count, data: client_data }
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
  end
end
