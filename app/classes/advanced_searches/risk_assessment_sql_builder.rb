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
      sql_string = 'clients.id IN (?)'
      sql = @field_name == 'level_of_risk' ? build_level_of_risk_sql : build_date_of_risk_assessment_sql
      client_risk_assessments = @clients.includes(:risk_assessment).where(sql)
      { id: sql_string, values: client_risk_assessments.ids }
    end

    private

    def build_level_of_risk_sql
      case @operator
      when 'equal'
        "risk_assessments.#{@field_name} = '#{@value}'"
      when 'not_equal'
        "risk_assessments.#{@field_name} != '#{@value}' OR risk_assessments.#{@field_name} IS NULL"
      when 'is_empty'
        "risk_assessments.#{@field_name} IS NULL"
      when 'is_not_empty'
        "risk_assessments.#{@field_name} IS NOT NULL"
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
  end
end
