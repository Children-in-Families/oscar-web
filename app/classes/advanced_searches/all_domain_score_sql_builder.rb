module AdvancedSearches
  class AllDomainScoreSqlBuilder

    def initialize(domain_id, rule, basic_rule)
      @operator     = rule['operator']
      @value        = rule['value']
      @domain_id    = domain_id
      @basic_rules  = basic_rule
    end

    def get_month_assessment_number(value)
      assess_number_rule = []
      if @basic_rules.any?{|rule| rule.kind_of?(Array)}
        @basic_rules.each do |rule|
          assess_number_rule = rule.reject{|rule| rule['field'] != value} if rule.kind_of?(Array)
        end
      else
        assess_number_rule = @basic_rules.reject{|rule| rule['field'] != value}
      end
      assess_number_rule[0]['value']
    end
    def get_sql
      sql_string = 'clients.id IN (?)'
      # sub_query = 'SELECT MAX(assessments.created_at) from assessments where assessments.client_id = clients.id'
      assessments = Assessment.joins([:assessment_domains, :client])

      case @operator
      when 'equal'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where(assessment_domains: {score: @value})
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where(assessment_domains: {score: @value})
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where(assessment_domains: {score: @value})
        end
      when 'not_equal'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: @value})
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: @value})
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: @value})
        end
      when 'less'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where('assessment_domains.score < ?', @value)
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where('assessment_domains.score < ?', @value)
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where('assessment_domains.score < ?', @value)
        end

      when 'less_or_equal'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where('assessment_domains.score <= ?', @value)
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where('assessment_domains.score <= ?', @value)
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where('assessment_domains.score <= ?', @value)
        end

      when 'greater'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where('assessment_domains.score > ?', @value)
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where('assessment_domains.score > ?', @value)
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where('assessment_domains.score > ?', @value)
        end

      when 'greater_or_equal'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where('assessment_domains.score >= ?', @value)
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where('assessment_domains.score >= ?', @value)
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where('assessment_domains.score >= ?', @value)
        end

      when 'between'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where(assessment_domains: {score: @value.first.to_i..@value.last.to_i})
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: @value.first.to_i..@value.last.to_i})
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: @value.first.to_i..@value.last.to_i})
        end

      when 'is_empty'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where(assessment_domains: {score: nil})
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where(assessment_domains: {score: nil})
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: nil})
        end

        # assessments = assessments.where('assessment_domains.score IS NOT NULL')
        # client_ids  = Client.where.not(id: assessments.distinct.pluck(:client_id)).ids
      when 'is_not_empty'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          assessments = assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: nil})
          return { id: sql_string, values: assessments.map(&:client_id) }

        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          month_number_value = get_month_assessment_number('month_number')
          assessment_date    = assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
          assessment_date    = assessment_date.beginning_of_month.to_date
          assessments        = assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month).group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: nil})
        else
          assessments = assessments.group(:id).group('assessment_domains.id').where.not(assessment_domains: {score: nil})
        end

        # assessments = assessments.where('assessment_domains.score IS NOT NULL')
      when 'assessment_has_changed'
        clients = Client.includes(:assessments).distinct.reject do |client|
          next if client.assessments.blank?
          limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1)).ids
          assessments = client.assessments.joins(:assessment_domains).group(:id).group('assessment_domains.id').where('assessment_domains.previous_score IS NOT NULL')
          (limit_assessments & assessments.ids).empty?
        end
        return { id: sql_string, values: clients.map(&:id) }
      when 'assessment_has_not_changed'
        clients = Client.includes(:assessments).distinct.reject do |client|
          next if client.assessments.blank?
          limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1)).ids
          assessments = client.assessments.joins(:assessment_domains).group(:id).group('assessment_domains.id').where('assessment_domains.previous_score IS NULL')
          (limit_assessments & assessments.ids).empty?
        end
        return { id: sql_string, values: clients.map(&:id) }
      when 'month_has_changed'
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients = clients.all.reject do |client|
          ordered_assessments = client.assessments.order(:created_at)
          start_date  = (ordered_assessments.first.created_at + (@value.first.to_i - 1).months).beginning_of_month.to_date
          end_date    = (ordered_assessments.first.created_at + (@value.last.to_i - 1).months).beginning_of_month.to_date
          all_assessments = ordered_assessments.where("date(assessments.created_at) IN (?)", start_date..end_date)
          assessments = all_assessments.joins(:assessment_domains).group(:id).group('assessment_domains.id').where("assessment_domains.previous_score IS NOT NULL")
          (all_assessments.ids & assessments.ids).empty?
        end
        return { id: sql_string, values: clients.map(&:id)}
      when 'month_has_not_changed'
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients = clients.all.reject do |client|
          ordered_assessments = client.assessments.order(:created_at)
          start_date  = (ordered_assessments.first.created_at + (@value.first.to_i - 1).months).beginning_of_month.to_date
          end_date    = (ordered_assessments.first.created_at + (@value.last.to_i - 1).months).beginning_of_month.to_date
          all_assessments = ordered_assessments.where("date(assessments.created_at) IN (?)", start_date..end_date)
          assessments = all_assessments.joins(:assessment_domains).group(:id).group('assessment_domains.id').where("assessment_domains.previous_score IS NULL")
          (all_assessments.ids & assessments.ids).empty?
        end
        return { id: sql_string, values: clients.map(&:id) }
      when 'average'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          if @basic_rules.any?{|rule| rule.kind_of?(Array)}
            @basic_rules.each do |rule|
              assess_number_rule = rule.reject{|rule| rule['field'] != 'assessment_number'} if rule.kind_of?(Array)
            end
          else
            assess_number_rule = @basic_rules.reject{|rule| rule['field'] != 'assessment_number'}
          end

          assess_number_value = assess_number_rule[0]['value']

          client_ids = []
          clients = Client.joins(:assessments).all.each do |client|
            assessment = client.assessments.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).first
            next if assessment.blank?
            score  = assessment.assessment_domains.average(:score).round
            next if score.nil?
            client_ids << client.id if score == @value.to_i
          end
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          if @basic_rules.any?{|rule| rule.kind_of?(Array)}
            @basic_rules.each do |rule|
              month_number_rule = rule.reject{|rule| rule['field'] != 'month_number'} if rule.kind_of?(Array)
            end
          else
            month_number_rule = @basic_rules.reject{|rule| rule['field'] != 'month_number'}
          end

          month_number_value = month_number_rule[0]['value']
          client_ids = []
          clients = Client.includes(:assessments).all.each do |client|
            next if client.assessments.blank?
            assessment_date = client.assessments.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
            assessment_date = assessment_date.beginning_of_month.to_date
            assessments  = client.assessments.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month)
            next if assessments.blank?

            scores = assessments.includes(:assessment_domains).map do |assessment|
                      assessment.assessment_domains.average(:score).round
                    end
            client_ids << client.id if (scores.compact.sum / client.assessments.count ).round == @value.to_i
          end
        else
          client_ids = []
          clients = Client.includes(:assessments).all.each do |client|
            next if client.assessments.blank?
            scores = client.assessments.includes(:assessment_domains).map do |assessment|
                      assessment.assessment_domains.average(:score)
                    end
            client_ids << client.id if (scores.compact.sum / client.assessments.count ).round == @value.to_i
          end
        end

        return { id: sql_string, values: client_ids.uniq }
      end

      client_ids  = assessments.uniq.pluck(:client_id) if assessments.present?
      return { id: sql_string, values: client_ids }

    end
  end
end