module AdvancedSearches
  class RiskAssessmentSqlBuilder
    def initialize(clients, field_name, operator, value)
      @clients = clients
      @field_name = field_name
      @operator = operator
      @value = value
    end

    def generate_sql
      sql = build_sql_queries

      client_ids = ActiveRecord::Base.connection.execute(sql).map { |row| row['id'] }
      { id: 'clients.id IN (?)', values: @clients.where(id: client_ids).ids }
    end

    private

    def build_sql_queries
      case @field_name
      when 'level_of_risk'
        build_level_of_risk_sql(@field_name)
      when 'date_of_risk_assessment'
        build_level_of_risk_sql('assessment_date')
      when 'has_known_chronic_disease'
        build_protection_concern_sql(@field_name)
      when 'has_disability'
        build_protection_concern_sql(@field_name)
      when 'has_hiv_or_aid'
        build_protection_concern_sql(@field_name)
      else
        'SELECT id FROM clients'
      end
    end

    def build_protection_concern_sql(field_name)
      case @operator
      when 'equal'
        build_risk_assessment_protect_concern_sql("#{field_name} = #{@value}")
      when 'not_equal'
        build_risk_assessment_protect_concern_sql("#{field_name} != #{@value}")
      when 'is_empty'
        build_risk_assessment_protect_concern_sql("#{field_name} IS NULL")
      when 'is_not_empty'
        build_risk_assessment_protect_concern_sql("#{field_name} IS NOT NULL")
      else
        'SELECT id FROM clients'
      end
    end

    def build_risk_assessment_protect_concern_sql(field_condition)
      <<~SQL
        SELECT clients.id
        FROM clients
        LEFT JOIN risk_assessments ON risk_assessments.client_id = clients.id
        WHERE (
          risk_assessments.#{field_condition} AND risk_assessments.client_id = clients.id
        )
      SQL
    end

    # SQL builders

    def build_level_of_risk_sql(field_name = 'level_of_risk')
      case @operator
      when 'equal'
        build_risk_assessment_level_of_risk_sql("#{field_name} = '#{@value}'")
      when 'not_equal'
        build_risk_assessment_level_of_risk_sql("#{field_name} != '#{@value}'")
      when 'is_empty'
        build_risk_assessment_level_of_risk_sql("#{field_name} IS NULL")
      when 'is_not_empty'
        build_risk_assessment_level_of_risk_sql("#{field_name} IS NOT NULL")
      when 'between'
        build_risk_assessment_level_of_risk_sql("#{field_name} BETWEEN '#{@value[0]}' AND '#{@value[1]}'")
      when 'less'
        build_risk_assessment_level_of_risk_sql("#{field_name} < '#{@value}'")
      when 'less_or_equal'
        build_risk_assessment_level_of_risk_sql("#{field_name} <= '#{@value}'")
      when 'greater'
        build_risk_assessment_level_of_risk_sql("#{field_name} > '#{@value}'")
      when 'greater_or_equal'
        build_risk_assessment_level_of_risk_sql("#{field_name} >= '#{@value}'")
      else
        ''
      end
    end

    def build_risk_assessment_level_of_risk_sql(level_of_risk_sql)
      assessment_sql = <<~SQL
        SELECT client_id, level_of_risk, assessment_date
        FROM assessments
        WHERE created_at = (
          SELECT MAX(created_at)
          FROM assessments
          WHERE client_id = clients.id AND level_of_risk IS NOT NULL
        )
      SQL

      <<~SQL
        SELECT clients.id
        FROM clients
        LEFT JOIN risk_assessments ON risk_assessments.client_id = clients.id
        WHERE (
          EXISTS (
            #{assessment_sql}
            AND #{level_of_risk_sql}
            AND client_id = clients.id
          )
          OR (
            NOT EXISTS (#{assessment_sql})
            AND risk_assessments.#{level_of_risk_sql}
            AND risk_assessments.client_id = clients.id
          )
        )
      SQL
    end
  end
end
