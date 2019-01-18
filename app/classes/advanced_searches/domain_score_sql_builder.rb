module AdvancedSearches
  class DomainScoreSqlBuilder

    def initialize(field, rule, basic_rule)
      @form_builder = field != nil ? field.split('_') : []
      @operator     = rule['operator']
      @value        = rule['value']
      @domain_id    = @form_builder.second
      @basic_rules  = basic_rule
      @field        = field
    end

    def get_sql
      sql_string = 'clients.id IN (?)'

      case @form_builder.first
      when 'domainscore'
        values = domainscore_field_query
      when 'all'
        values = all_domains_query
      end
      { id: sql_string, values: values }
    end

    def domainscore_field_query
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
        client_ids  = Client.where.not(id: assessments.distinct.pluck(:client_id)).ids
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
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients = clients.all.reject do |client|
          ordered_assessments = client.assessments.order(:created_at)
          start_date  = (ordered_assessments.first.created_at + (@value.first.to_i - 1).months).beginning_of_month.to_date
          end_date    = (ordered_assessments.first.created_at + (@value.last.to_i - 1).months).beginning_of_month.to_date
          all_assessments = ordered_assessments.where("date(assessments.created_at) IN (?)", start_date..end_date)
          assessments = all_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score IS NOT NULL", @domain_id)
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
          assessments = all_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score IS NULL", @domain_id)
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
            score  = assessment.assessment_domains.where(domain_id: @domain_id).first.try(:score)
            next if score.nil?
            client_ids << client.id if score.to_i == @value.to_i
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
                      next if assessment.assessment_domains.where(domain_id: @domain_id).blank?
                      assessment.assessment_domains.where(domain_id: @domain_id).first.try(:score)
                    end
            client_ids << client.id if (scores.compact.sum / assessments.count ).round == @value.to_i
          end
        else
          client_ids = []
          clients = Client.includes(:assessments).all.each do |client|
            next if client.assessments.blank?
            scores = client.assessments.includes(:assessment_domains).map do |assessment|
                      next if assessment.assessment_domains.where(domain_id: @domain_id).blank?
                      assessment.assessment_domains.where(domain_id: @domain_id).first.try(:score)
                    end
            client_ids << client.id if (scores.compact.sum / client.assessments.count ).round == @value.to_i
          end
        end
        return { id: sql_string, values: client_ids.uniq }
      end

      client_ids = assessments.uniq.pluck(:client_id) unless @operator == 'is_empty'
    end

    def all_domains_query
      # assessments = Assessment.joins([:assessment_domains, :client])
      case @operator
      when 'equal'
        return domainscore_query('equal')
      when 'not_equal'
        return domainscore_query('not_equal')
      when 'less'
        return domainscore_query('less')
      when 'less_or_equal'
        return domainscore_query('less_or_equal')
      when 'greater'
        return domainscore_query('greater')
      when 'greater_or_equal'
        return domainscore_query('greater_or_equal')
      when 'is_empty'
        return domainscore_query('is_empty')
      when 'is_not_empty'
        return domainscore_query('is_not_empty')
      when 'average'
        return domainscore_query('average')
      end
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

    def domainscore_query(operator)
      if @field == 'all_domains'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          clients = Client.joins(assessments: :assessment_domains).reject do |client|
            assessment = client.assessments.defaults.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).first
            scores = assessment.assessment_domains.pluck(:score) if assessment.present?
            next if scores.blank?
            conditions = []
            if operator == 'equal'
              scores.exclude?(@value.to_i)
              # scores.uniq != [@value.to_i]
            elsif operator == 'not_equal'
              scores.include?(@value.to_i)
            elsif operator == 'less'
              scores.compact.each {|score| conditions << (score > @value.to_i or score == @value.to_i) }
              conditions.include?(true)
            elsif operator == 'greater'
              scores.compact.each {|score| conditions << (score < @value.to_i or score == @value.to_i) }
              conditions.include?(true)
            elsif operator == 'less_or_equal'
              scores.compact.each {|score| conditions << (score > @value.to_i) }
              conditions.include?(true)
            elsif operator == 'greater_or_equal'
              scores.compact.each {|score| conditions << (score < @value.to_i) }
              conditions.include?(true)
            elsif operator == 'is_empty'
              scores.compact.any?
            elsif operator == 'is_not_empty'
              assessment.assessment_domains.size != scores.compact.size
            elsif operator == 'average'
              (scores.compact.sum / assessment.assessment_domains.size).round != @value.to_i
            end
          end
          clients.map(&:id)
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          clients = Client.joins(assessments: :assessment_domains).reject do |client|
            month_number_value = get_month_assessment_number('month_number')
            assessment_date    = client.assessments.defaults.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
            assessment_date    = assessment_date.beginning_of_month.to_date
            assessments        = client.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month)
            next if assessments.blank?
            conditions = []
            assessment = assessments.includes(:assessment_domains).each do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              if operator == 'equal'
                conditions << true if scores.exclude?(@value.to_i)
                # conditions << true if scores.uniq != [@value.to_i]
              elsif operator == 'not_equal'
                conditions << true if scores.include?(@value.to_i)
              elsif operator == 'less'
                scores.compact.each {|score| conditions << (score > @value.to_i or score == @value.to_i) }
              elsif operator == 'greater'
                scores.compact.each {|score| conditions << (score < @value.to_i or score == @value.to_i) }
              elsif operator == 'less_or_equal'
                scores.compact.each {|score| conditions << (score > @value.to_i) }
              elsif operator == 'greater_or_equal'
                scores.compact.each {|score| conditions << (score < @value.to_i) }
              elsif operator == 'is_empty'
                conditions << true if scores.compact.any?
              elsif operator == 'is_not_empty'
                conditions << true if assessment.assessment_domains.size != scores.compact.size
              elsif operator == 'average'
                conditions << (scores.compact.sum / assessment.assessment_domains.size).round != @value.to_i
              end
            end
            conditions.include?(true)
          end
          clients.map(&:id)
        else
          client_ids = Client.includes(assessments: :assessment_domains).map do |client|
            next if client.assessments.defaults.blank?
            assessment = client.assessments.defaults.includes(:assessment_domains).reject do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              conditions = []
              if operator == 'equal'
                scores.exclude?(@value.to_i)
                # scores.uniq != [@value.to_i]
              elsif operator == 'not_equal'
                scores.include?(@value.to_i)
              elsif operator == 'less'
                scores.compact.each {|score| conditions << (score > @value.to_i or score == @value.to_i) }
                conditions.include?(true)
              elsif operator == 'greater'
                scores.compact.each {|score| conditions << (score < @value.to_i or score == @value.to_i) }
                conditions.include?(true)
              elsif operator == 'less_or_equal'
                scores.compact.each {|score| conditions << (score > @value.to_i) }
                conditions.include?(true)
              elsif operator == 'greater_or_equal'
                scores.compact.each {|score| conditions << (score < @value.to_i) }
                conditions.include?(true)
              elsif operator == 'is_empty'
                scores.compact.any?
              elsif operator == 'is_not_empty'
                assessment.assessment_domains.size != scores.compact.size
              elsif operator == 'average'
                (scores.compact.sum / assessment.assessment_domains.size).round != @value.to_i
              end
            end
            assessment.first.try(:client_id)
          end
          client_ids.compact
        end
      elsif @field == 'all_custom_domains'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          clients = Client.joins(assessments: :assessment_domains).reject do |client|
            assessment = client.assessments.customs.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).first
            scores = assessment.assessment_domains.pluck(:score) if assessment.present?
            next if scores.blank?
            conditions = []
            if operator == 'equal'
              scores.exclude?(@value.to_i)
              # scores.uniq != [@value.to_i]
            elsif operator == 'not_equal'
              scores.include?(@value.to_i)
            elsif operator == 'less'
              scores.compact.each {|score| conditions << (score > @value.to_i or score == @value.to_i) }
              conditions.include?(true)
            elsif operator == 'greater'
              scores.compact.each {|score| conditions << (score < @value.to_i or score == @value.to_i) }
              conditions.include?(true)
            elsif operator == 'less_or_equal'
              scores.compact.each {|score| conditions << (score > @value.to_i) }
              conditions.include?(true)
            elsif operator == 'greater_or_equal'
              scores.compact.each {|score| conditions << (score < @value.to_i) }
              conditions.include?(true)
            elsif operator == 'is_empty'
              scores.compact.any?
            elsif operator == 'is_not_empty'
              assessment.assessment_domains.size != scores.compact.size
            elsif operator == 'average'
              (scores.compact.sum / assessment.assessment_domains.size).round != @value.to_i
            end
          end
          clients.map(&:id)
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          clients = Client.joins(assessments: :assessment_domains).reject do |client|
            month_number_value = get_month_assessment_number('month_number')
            assessment_date    = client.assessments.customs.order(:created_at).first.created_at + (month_number_value.to_i - 1).month
            assessment_date    = assessment_date.beginning_of_month.to_date if assessment_date.present?
            assessments        = client.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", assessment_date, assessment_date.end_of_month)
            next if assessments.blank?
            conditions = []
            assessment = assessments.includes(:assessment_domains).each do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              if operator == 'equal'
                conditions << true if scores.exclude?(@value.to_i)
                # conditions << true if scores.uniq != [@value.to_i]
              elsif operator == 'not_equal'
                conditions << true if scores.include?(@value.to_i)
              elsif operator == 'less'
                scores.compact.each {|score| conditions << (score > @value.to_i or score == @value.to_i) }
              elsif operator == 'greater'
                scores.compact.each {|score| conditions << (score < @value.to_i or score == @value.to_i) }
              elsif operator == 'less_or_equal'
                scores.compact.each {|score| conditions << (score > @value.to_i) }
              elsif operator == 'greater_or_equal'
                scores.compact.each {|score| conditions << (score < @value.to_i) }
              elsif operator == 'is_empty'
                conditions << true if scores.compact.any?
              elsif operator == 'is_not_empty'
                conditions << true if assessment.assessment_domains.size != scores.compact.size
              elsif operator == 'average'
                conditions << (scores.compact.sum / assessment.assessment_domains.size).round != @value.to_i
              end
            end
            conditions.include?(true)
          end
          clients.map(&:id)
        else
          client_ids = Client.includes(assessments: :assessment_domains).map do |client|
            next if client.assessments.customs.blank?
            assessment = client.assessments.customs.includes(:assessment_domains).reject do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              conditions = []
              if operator == 'equal'
                scores.exclude?(@value.to_i)
                # scores.uniq != [@value.to_i]
              elsif operator == 'not_equal'
                scores.include?(@value.to_i)
              elsif operator == 'less'
                scores.compact.each {|score| conditions << (score > @value.to_i or score == @value.to_i) }
                conditions.include?(true)
              elsif operator == 'greater'
                scores.compact.each {|score| conditions << (score < @value.to_i or score == @value.to_i) }
                conditions.include?(true)
              elsif operator == 'less_or_equal'
                scores.compact.each {|score| conditions << (score > @value.to_i) }
                conditions.include?(true)
              elsif operator == 'greater_or_equal'
                scores.compact.each {|score| conditions << (score < @value.to_i) }
                conditions.include?(true)
              elsif operator == 'is_empty'
                scores.compact.any?
              elsif operator == 'is_not_empty'
                assessment.assessment_domains.size != scores.compact.size
              elsif operator == 'average'
                (scores.compact.sum / assessment.assessment_domains.size).round != @value.to_i
              end
            end
            assessment.first.try(:client_id)
          end
          client_ids.compact
        end
      end
    end
  end
end
