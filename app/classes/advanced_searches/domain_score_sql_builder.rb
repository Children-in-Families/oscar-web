module AdvancedSearches
  class DomainScoreSqlBuilder

    def initialize(domain_id, rule)
      @operator     = rule['operator']
      @value        = rule['value']
      @domain_id    = domain_id
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      sub_query = 'SELECT MAX(assessments.created_at) from assessments where assessments.client_id = clients.id'
      assessments = Assessment.joins([:assessment_domains, :client]).where("assessments.created_at = (#{sub_query})")

      case @operator
      when 'equal'
        assessments = assessments.where(assessment_domains: { domain_id: @domain_id, score: @value })
      when 'not_equal'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score != ?', @domain_id, @value)
      when 'less'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score < ?', @domain_id, @value)
      when 'less_or_equal'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score <= ?', @domain_id, @value)
      when 'greater'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score > ?', @domain_id, @value)
      when 'greater_or_equal'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score >= ?', @domain_id, @value)
      when 'between'
        assessments = assessments.where(assessment_domains: { domain_id: @domain_id, score: @value.first..@value.last })
      when 'is_empty'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score IS NOT NULL', @domain_id)
        client_ids = Client.where.not(id: assessments.pluck(:client_id).uniq).pluck(:id).uniq
      when 'is_not_empty'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score IS NOT NULL', @domain_id)
      when 'assessment_has_changed'
        clients = Client.includes(:assessments).distinct.reject do |client|
          next if client.assessments.blank?
          limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1)).ids
          assessments = client.assessments.joins(:assessment_domains).where('assessment_domains.domain_id = ? and assessment_domains.previous_score IS NOT NULL', @domain_id)
          (limit_assessments & assessments.ids).empty?
        end
        return { id: sql_string, values: clients.map(&:id) }
      when 'assessment_has_not_changed'
        clients = Client.includes(:assessments).distinct.reject do |client|
          next if client.assessments.blank?
          limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1)).ids
          assessments = client.assessments.joins(:assessment_domains).where('assessment_domains.domain_id = ? and assessment_domains.previous_score IS NULL', @domain_id)
          (limit_assessments & assessments.ids).empty?
        end
        return { id: sql_string, values: clients.map(&:id) }
      when 'month_has_changed'

      when 'month_has_not_changed'

      when 'average'

      end
      client_ids = assessments.uniq.pluck(:client_id) unless @operator == 'is_empty'
      { id: sql_string, values: client_ids }
    end
  end
end
