class Family::AssessmentsController < Api::ApplicationController
  include FamilyAdvancedSearchesConcern

  def index
    $param_rules = params
    basic_rules = JSON.parse(params[:basic_rules] || '{}')
    families = AdvancedSearches::Families::FamilyAdvancedSearch.new(basic_rules, Family.accessible_by(current_ability)).filter
    assessments = Assessment.joins(:family).where(default: false, family_id: families.ids)
    @assessments_count = assessments.count

    render json: { recordsTotal: @assessments_count, recordsFiltered: @assessments_count, data: data }
  end

  private

  def data
    assessment_domain_hash = {}
    client_data = []
    assessment_data.each do |assessment|
      assessment_domain_hash = AssessmentDomain.where(assessment_id: assessment.id).pluck(:domain_id, :score).to_h if assessment.assessment_domains.present?
      domain_scores = domains.map { |domain| assessment_domain_hash.present? ? ["domain_#{domain.id}", assessment_domain_hash[domain.id]] : ["domain_#{domain.id}", ''] }
      total = 0
      assessment_domain_hash.each do |index, value|
        total += value || 0
      end

      client_hash = {
        id: assessment.family_id,
        name: assessment.family.name,
        'assessment-number': assessment.family.assessments.count,
        date: assessment.created_at.strftime('%d %B %Y'),
        'average-score': total.zero? ? nil : total.fdiv(domain_scores.length).round
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
    basic_rules = JSON.parse(params[:basic_rules] || '{}')
    families = AdvancedSearches::Families::FamilyAdvancedSearch.new(basic_rules, Family.accessible_by(current_ability)).filter
    assessments = Assessment.joins(:family).where(default: false, family_id: families.ids)

    assessment_data = params[:length] != '-1' ? assessments.page(page).per(per_page) : assessments
  end

  def domains
    Domain.family_custom_csi_domains.order_by_identity
  end

  def page
    params[:start].to_i / per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    domains_fields = domains.map { |domain| 'assessment_domains.score' }
    columns = ["regexp_replace(clients.slug, '\\D*', '', 'g')::int", 'clients.given_name', 'clients.assessments_count', 'assessments.created_at', *domains_fields]
    columns[params[:order]['0']['column'].to_i]
  end

  def sort_direction
    params[:order]['0']['dir'] == 'desc' ? 'desc' : 'asc'
  end

  def adule_client_gender_count(clients, type = :male)
    clients.public_send(type).where('(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= ?', 18).count
  end

  def under_18_client_gender_count(clients, type = :male)
    clients.public_send(type).where('(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) < ?', 18).count
  end

  def other_client_gender_count(clients)
    clients.where("gender IS NULL OR (gender NOT IN ('male', 'female'))").count
  end
end
