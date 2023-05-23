module AdvancedSearches
  class RiskAssessmentSqlBuilder
    def initialize(clients, field_name, operator, value)
      @clients = clients
      @field_name = field_name
      @operator = operator
      @value = value
      basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      @basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    end

    def generate_sql
      client_risk_assessment_ids = []
      sql_string = 'clients.id IN (?)'
      sql = @field_name == 'level_of_risk' ? build_level_of_risk_sql : build_date_of_risk_assessment_sql
      assessment_sql = @field_name == 'level_of_risk' ? build_assessment_level_of_risk_sql : build_assessment_date_of_risk_assessment_sql

      client_risk_assessments = @clients.includes(:risk_assessment).where(sql)
      client_risk_assessments = client_risk_assessments.includes(:assessments).references(:assessments).where(assessment_sql)
      risk_assessment_clients = @clients.includes(:assessments).references(:assessments).where(assessment_sql)

      if @operator == 'not_equal'
        clients = @clients.includes(:assessments).references(:assessments).group('clients.id, assessments.id').having('COUNT(assessments.*) = 0')
        client_risk_assessment_ids = clients.includes(:risk_assessment).where(sql).ids
      end
      { id: sql_string, values: client_risk_assessments.ids + risk_assessment_clients.ids + client_risk_assessment_ids }
    end

    private

    def build_level_of_risk_sql
      case @operator
      when 'equal'
        "risk_assessments.level_of_risk = '#{@value}'"
      when 'not_equal'
        "risk_assessments.level_of_risk != '#{@value}' OR risk_assessments.level_of_risk IS NULL"
      when 'is_empty'
        'risk_assessments.level_of_risk IS NULL'
      when 'is_not_empty'
        'risk_assessments.level_of_risk IS NOT NULL'
      end
    end

    def build_date_of_risk_assessment_sql
      case @operator
      when 'equal'
        "date(risk_assessments.assessment_date) = '#{@value}'"
      when 'not_equal'
        "date(risk_assessments.assessment_date) != '#{@value}'"
      when 'less'
        "date(risk_assessments.assessment_date) < '#{@value}'"
      when 'less_or_equal'
        "date(risk_assessments.assessment_date) <= '#{@value}'"
      when 'greater'
        "date(risk_assessments.assessment_date) > '#{@value}'"
      when 'greater_or_equal'
        "date(risk_assessments.assessment_date) >= '#{@value}'"
      when 'is_empty'
        'date(risk_assessments.assessment_date) IS NULL'
      when 'is_not_empty'
        'date(risk_assessments.assessment_date) IS NOT NULL'
      when 'between'
        "date(risk_assessments.assessment_date) BETWEEN '#{@value.first}' AND '#{@value.last}'"
      end
    end

    def build_assessment_level_of_risk_sql
      case @operator
      when 'equal'
        "assessments.level_of_risk = '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'not_equal'
        "(assessments.level_of_risk != '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1))"
      when 'is_empty'
        'assessments.level_of_risk IS NULL'
      when 'is_not_empty'
        'assessments.level_of_risk IS NOT NULL'
      end
    end

    def build_assessment_date_of_risk_assessment_sql
      case @operator
      when 'equal'
        "date(assessments.assessment_date) = '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'not_equal'
        "date(assessments.assessment_date) != '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'less'
        "date(assessments.assessment_date) < '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'less_or_equal'
        "date(assessments.assessment_date) <= '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'greater'
        "date(assessments.assessment_date) > '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'greater_or_equal'
        "date(assessments.assessment_date) >= '#{@value}' AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      when 'is_empty'
        'date(assessments.assessment_date) IS NULL'
      when 'is_not_empty'
        'date(assessments.assessment_date) IS NOT NULL AND assessments.level_of_risk IS NOT NULL'
      when 'between'
        "assessments.level_of_risk IS NOT NULL AND (date(assessments.assessment_date) BETWEEN '#{@value.first}' AND '#{@value.last}') AND assessments.id=(SELECT assessments.id FROM assessments WHERE assessments.client_id = clients.id ORDER BY assessments.id DESC LIMIT 1)"
      end
    end
  end
end
