module AdvancedSearches
  class RiskAssessmentSqlBuilder
    def initialize(clients, field_name, operator, value)
      @clients = clients
      @field_name = field_name
      @operator = operator
      @value = value
    end

    def generate_sql
      sql, assessment_sql = build_sql_queries

      client_risk_assessment_ids = find_client_risk_assessment_ids(sql)
      client_risk_assessment_ids = find_client_assessment_ids(assessment_sql) if client_risk_assessment_ids.blank?

      { id: 'clients.id IN (?)', values: client_risk_assessment_ids }
    end

    private

    def find_client_risk_assessment_ids(sql)
      if sql.present?
        clients = @clients.joins(:risk_assessment).where(sql)
        clients = clients.group('clients.id').having('COUNT(*) = 0') if @operator == 'not_equal'
      elsif @operator == 'is_empty'
        clients = @clients.includes(:risk_assessment).references(:risk_assessments).group('clients.id').having('COUNT(risk_assessments.*) = 0')
      elsif @operator == 'is_not_empty'
        clients = @clients.joins(:risk_assessment).group('clients.id').having('COUNT(risk_assessments.*) > 0')
      end
      clients.pluck(:id)
    end

    def build_sql_queries
      case @field_name
      when 'level_of_risk'
        [build_level_of_risk_sql, build_assessment_level_of_risk_sql]
      when 'date_of_risk_assessment'
        [build_date_of_risk_assessment_sql, build_assessment_date_of_risk_assessment_sql]
      when 'has_known_chronic_disease'
        [build_protection_concern_sql('has_known_chronic_disease'), '']
      when 'has_disability'
        [build_protection_concern_sql('has_disability'), '']
      when 'has_hiv_or_aid'
        [build_protection_concern_sql('has_hiv_or_aid'), '']
      else
        ['', '']
      end
    end

    # implement method called build_protection_concern_sql to build sql for protection concern
    # it has dynamic field name as parameter
    def build_protection_concern_sql(field_name)
      case @operator
      when 'equal'
        ["risk_assessments.#{field_name} = ?", @value]
      when 'not_equal'
        ["risk_assessments.#{field_name} != ?", @value]
      when 'is_empty'
        []
      when 'is_not_empty'
        []
      else
        ['', '']
      end
    end

    def find_client_assessment_ids(sql)
      clients = @clients.joins(:assessments).where(sql)
      clients = clients.group('clients.id').having('COUNT(*) = 0') if @operator == 'not_equal'
      clients.pluck(:id)
    end

    # SQL builders

    def build_level_of_risk_sql
      case @operator
      when 'equal'
        ["risk_assessments.level_of_risk = ?", @value]
      when 'not_equal'
        ["risk_assessments.level_of_risk != ? OR risk_assessments.level_of_risk IS NULL", @value]
      when 'is_empty'
        ['risk_assessments.level_of_risk IS NULL']
      when 'is_not_empty'
        ['risk_assessments.level_of_risk IS NOT NULL']
      else
        ['', '']
      end
    end

    def build_date_of_risk_assessment_sql
      case @operator
      when 'equal'
        ["date(risk_assessments.assessment_date) = ?", @value]
      when 'not_equal'
        ["date(risk_assessments.assessment_date) != ?", @value]
      when 'less'
        ["date(risk_assessments.assessment_date) < ?", @value]
      when 'less_or_equal'
        ["date(risk_assessments.assessment_date) <= ?", @value]
      when 'greater'
        ["date(risk_assessments.assessment_date) > ?", @value]
      when 'greater_or_equal'
        ["date(risk_assessments.assessment_date) >= ?", @value]
      when 'is_empty'
        ['date(risk_assessments.assessment_date) IS NULL']
      when 'is_not_empty'
        ['date(risk_assessments.assessment_date) IS NOT NULL']
      when 'between'
        ["date(risk_assessments.assessment_date) BETWEEN ? AND ?", @value.first, @value.last]
      else
        ['', '']
      end
    end

    def build_assessment_level_of_risk_sql
      case @operator
      when 'equal'
        [
          "assessments.level_of_risk = ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'not_equal'
        [
          "assessments.level_of_risk != ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'is_empty'
        ['assessments.level_of_risk IS NULL']
      when 'is_not_empty'
        ['assessments.level_of_risk IS NOT NULL']
      else
        ['', '']
      end
    end

    def build_assessment_date_of_risk_assessment_sql
      case @operator
      when 'equal'
        [
          "date(assessments.assessment_date) = ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'not_equal'
        [
          "date(assessments.assessment_date) != ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'less'
        [
          "date(assessments.assessment_date) < ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'less_or_equal'
        [
          "date(assessments.assessment_date) <= ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'greater'
        [
          "date(assessments.assessment_date) > ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'greater_or_equal'
        [
          "date(assessments.assessment_date) >= ? AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value
        ]
      when 'is_empty'
        ['date(assessments.assessment_date) IS NULL']
      when 'is_not_empty'
        ['date(assessments.assessment_date) IS NOT NULL AND assessments.level_of_risk IS NOT NULL']
      when 'between'
        [
          "assessments.level_of_risk IS NOT NULL AND (date(assessments.assessment_date) BETWEEN ? AND ?) AND assessments.id = (SELECT id FROM assessments WHERE client_id = clients.id ORDER BY id DESC LIMIT 1)",
          @value.first, @value.last
        ]
      else
        ['', '']
      end
    end
  end
end
