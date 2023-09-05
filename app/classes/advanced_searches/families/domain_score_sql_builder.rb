module AdvancedSearches
  class Families::DomainScoreSqlBuilder
    include AssessmentHelper
    def initialize(field, rule, basic_rule)
      @form_builder = field != nil ? field.split('__') : []
      @operator     = rule['operator']
      @value        = rule['value']
      @domain_id    = @form_builder.second
      @basic_rules  = basic_rule
      @field        = field
    end

    def get_sql
      sql_string = 'families.id IN (?)'
      case @form_builder.first
      when 'domainscore'
        values = domainscore_field_query
      when 'all_custom_domains'
        values = all_domains_query
      end
      { id: sql_string, values: values }
    end

    def return_dates(custom_domain, family)
      if custom_domain == true
        ordered_assessments = family.assessments.customs.order(:created_at)
      else
        ordered_assessments = family.assessments.defaults.order(:created_at)
      end

      dates = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
    end

    def domainscore_field_query
      assessments   = []
      domain        = Domain.find(@domain_id)
      custom_domain = domain&.custom_domain
      identity      = domain.identity
      families      = Family.joins(assessments: :assessment_domains)

      if $param_rules.nil?
        families.ids
      else
        basic_rules = $param_rules['basic_rules']
        basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
        results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
        assessment_completed_sql, assessment_number = assessment_filter_values(results)
        sql = "(assessments.completed = true #{assessment_completed_sql}) AND assessments.created_at = (SELECT created_at FROM assessments WHERE families.id = assessments.family_id ORDER BY assessments.created_at limit 1 offset #{(assessment_number || 1) - 1})".squish
        if assessment_completed_sql.present? && assessment_number.present?
          families = families.where(assessment_domains: { score: @value.to_i, domain_id: @domain_id }).where(sql)
        else
          family_ids = families.where(assessment_domains: { domain_id: @domain_id }).ids
          assessments = Assessment.where(family_id: family_ids)
          return family_ids = assessment_filter_domainscore_query(assessments.to_a)
        end
        families.ids
      end
    end

    def score_change_query
      return if @value.first == @value.last
      family_ids = []
      between_date_value = @basic_rules.second['value']
      custom_domain      = Domain.find(@domain_id)&.custom_domain

      case @operator
      when 'assessment_has_changed'
        Family.includes(:assessments).distinct.each do |family|
          next if (family.assessments.blank? || family.assessments.count < @value.last.to_i)
          dates     = return_dates(custom_domain, family)
          date_from = between_date_value[0].to_date
          date_to   = between_date_value[1].to_date
          next unless dates[@value.first.to_i-1].present? && dates[@value.last.to_i-1].present?
          next unless (dates[@value.first.to_i-1].to_date >= date_from && dates[@value.last.to_i-1].to_date <= date_to)

          date      = dates.uniq[@value.last.to_i-1]
          if date.present?
            if custom_domain == true
              number_assessments = family.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            else
              number_assessments = family.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            end
            number_assessments  = number_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score != assessment_domains.score", @domain_id) if number_assessments.present?
            family_ids          << family.id if number_assessments.present?
          end
        end
      when 'assessment_has_not_changed'
        Family.includes(:assessments).distinct.each do |family|
          next if (family.assessments.blank? || family.assessments.count < @value.last.to_i)
          dates     = return_dates(custom_domain, family)
          date_from = between_date_value[0].to_date
          date_to   = between_date_value[1].to_date
          next unless dates[@value.first.to_i-1].present? && dates[@value.last.to_i-1].present?
          next unless (dates[@value.first.to_i-1].to_date >= date_from && dates[@value.last.to_i-1].to_date <= date_to)

          date      = dates.uniq[@value.last.to_i-1]
          if date.present?
            if custom_domain == true
              number_assessments  = family.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            else
              number_assessments  = family.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            end
            number_assessments  = number_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND (assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score)", @domain_id) if number_assessments.present?
            family_ids          << family.id if number_assessments.present?
          end
        end
      when 'month_has_changed'
        families = Family.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        families.all.each do |family|
          dates     = return_dates(custom_domain, family)
          date_from = between_date_value[0].to_date
          date_to   = between_date_value[1].to_date
          next unless dates.uniq[@value.first.to_i-1].present? && dates.uniq[@value.last.to_i-1].present?
          next unless (dates.uniq[@value.first.to_i-1].to_date >= date_from && dates.uniq[@value.last.to_i-1].to_date <= date_to)

          date      = dates.uniq[@value.last.to_i-1]
          if date.present?
            if custom_domain == true
              month_assessments = family.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            else
              month_assessments = family.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            end
            month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score != assessment_domains.score", @domain_id) if month_assessments.present?
            family_ids          << family.id if month_assessments.present?
          end
        end
      when 'month_has_not_changed'
        families = Family.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        families.all.each do |family|
          dates     = return_dates(custom_domain, family)
          date_from = between_date_value[0].to_date
          date_to   = between_date_value[1].to_date
          next unless dates.uniq[@value.first.to_i-1].present? && dates.uniq[@value.last.to_i-1].present?
          next unless (date_from >= dates.uniq[@value.first.to_i-1].to_date && dates.uniq[@value.last.to_i-1].to_date <= date_to)

          date      = dates.uniq[@value.last.to_i-1]
          if date.present?
            if custom_domain == true
              month_assessments = family.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            else
              month_assessments = family.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month)
            end
            month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND (assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score)", @domain_id) if month_assessments.present?
            family_ids          << family.id if month_assessments.present?
          end
        end
      end
      return family_ids.uniq
    end

    def assessment_filter_domainscore_query(assessments)
      family_ids = []

      case @operator
      when 'equal'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where(domain_id: @domain_id, score: @value)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'not_equal'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score != ?', @domain_id, @value)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'less'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score < ?', @domain_id, @value)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'less_or_equal'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score <= ?', @domain_id, @value)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'greater'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score > ?', @domain_id, @value)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'greater_or_equal'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score >= ?', @domain_id, @value)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'is_empty'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score IS NULL', @domain_id)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      when 'is_not_empty'
        assessments.compact.uniq.each do |id|
          assessment_domains = AssessmentDomain.where(assessment_id: id).where('domain_id = ? and score IS NOT NULL', @domain_id)
          family_ids << assessment_domains.map(&:family_id) if assessment_domains.any?
        end
      end

      return family_ids.uniq
    end

    def only_domainscore_field_query
      assessments = Assessment.joins([:assessment_domains, :family])

      case @operator
      when 'equal'
        assessments = assessments.where(assessment_domains: { domain_id: @domain_id, score: @value })
      when 'not_equal'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score != ?', @domain_id, @value)
      when 'less'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score < ?', @domain_id, @value)
      when 'less_or_equal'
        return if @domain_id.blank?
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score <= ?', @domain_id, @value)
      when 'greater'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score > ?', @domain_id, @value)
      when 'greater_or_equal'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score >= ?', @domain_id, @value)
      when 'between'
        assessments = assessments.where(assessment_domains: { domain_id: @domain_id, score: @value.first..@value.last })
      when 'is_empty'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score IS NOT NULL', @domain_id)
        family_ids  = Family.where.not(id: assessments.distinct.pluck(:family_id)).ids
      when 'is_not_empty'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score IS NOT NULL', @domain_id)
      when 'assessment_has_changed'
        return if @value.first == @value.last
        family_ids = []
        families = Family.includes(:assessments).distinct.each do |family|
          next if (family.assessments.blank? || family.assessments.count < @value.last.to_i)
          limit_assessments = family.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1))
          assessment        = limit_assessments.last.assessment_domains.where('assessment_domains.domain_id = ? and assessment_domains.previous_score != assessment_domains.score', @domain_id) if limit_assessments.present?
          family_ids        << family.id if assessment.present?
        end
        return family_ids.flatten.uniq
      when 'assessment_has_not_changed'
        return if @value.first == @value.last
        family_ids = []
        families = Family.includes(:assessments).distinct.each do |family|
          next if (family.assessments.blank? || family.assessments.count < @value.last.to_i)
          limit_assessments = family.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1))
          assessment        = limit_assessments.last.assessment_domains.where('assessment_domains.domain_id = ? and (assessment_domains.previous_score IS NULL or assessment_domains.previous_score = assessment_domains.score)', @domain_id) if limit_assessments.present?
          family_ids        << family.id if assessment.present?
        end
        return family_ids.flatten.uniq
      when 'month_has_changed'
        return if @value.first == @value.last
        family_ids = []
        families = Family.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        families = families.all.each do |family|
          ordered_assessments = family.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date                = dates.uniq[@value.last.to_i-1]
          month_assessments   = family.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score != assessment_domains.score", @domain_id) if month_assessments.present?
          family_ids << family.id if month_assessments.present?
        end
        return family_ids.flatten.uniq
      when 'month_has_not_changed'
        return if @value.first == @value.last
        family_ids = []
        families = Family.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        families = families.all.each do |family|
          ordered_assessments = family.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date                = dates.uniq[@value.last.to_i-1]
          month_assessments   = family.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND (assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score)", @domain_id) if month_assessments.present?
          family_ids << family.id if month_assessments.present?
        end
        return family_ids.flatten.uniq
      end
      family_ids = assessments.uniq.pluck(:family_id) unless @operator == 'is_empty'
    end

    def all_domains_query
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

    def domainscore_query(operator)
      if @field == 'all_domains'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          families = Family.joins(assessments: :assessment_domains).reject do |family|
            assessment = family.assessments.defaults.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).first
            scores = assessment.assessment_domains.pluck(:score) if assessment.present?
            next if scores.blank?
            conditions = []
            if operator == 'equal'
              scores.exclude?(@value.to_i)
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
              (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
            end
          end
          families.map(&:id)
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          families = Family.joins(assessments: :assessment_domains).reject do |family|
            month_number_value  = get_month_assessment_number('month_number')
            ordered_assessments = family.assessments.defaults.order(:created_at)
            dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
            date                = dates.uniq[month_number_value-1]
            assessments         = family.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?

            next if assessments.blank?
            conditions = []
            assessment = assessments.includes(:assessment_domains).each do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              if operator == 'equal'
                conditions << true if scores.exclude?(@value.to_i)
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
                conditions << true if (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
              end
            end
            conditions.include?(true)
          end
          families.map(&:id).uniq
        else
          family_ids = Family.includes(assessments: :assessment_domains).map do |family|
            next if family.assessments.defaults.blank?
            assessment = family.assessments.defaults.includes(:assessment_domains).reject do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              conditions = []
              if operator == 'equal'
                scores.exclude?(@value.to_i)
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
                (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
              end
            end
            assessment.first.try(:family_id)
          end
          family_ids.compact
        end
      elsif @field == 'all_custom_domains'
        if @basic_rules.flatten.any?{|rule| rule['field'] == 'assessment_number'}
          assess_number_value = get_month_assessment_number('assessment_number')
          families = Family.joins(assessments: :assessment_domains).reject do |family|
            assessment = family.assessments.customs.order(:created_at).limit(1).offset(assess_number_value.to_i - 1).first
            scores = assessment.assessment_domains.pluck(:score) if assessment.present?
            next if scores.blank?
            conditions = []
            if operator == 'equal'
              scores.exclude?(@value.to_i)
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
              (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
            end
          end
          families.map(&:id)
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          families = Family.joins(assessments: :assessment_domains).reject do |family|
            month_number_value  = get_month_assessment_number('month_number')
            ordered_assessments = family.assessments.customs.order(:created_at)
            dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
            date                = dates.uniq[month_number_value-1]
            assessments         = family.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?

            next if assessments.blank?
            conditions = []
            assessment = assessments.includes(:assessment_domains).each do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              if operator == 'equal'
                conditions << true if scores.exclude?(@value.to_i)
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
                conditions << true if (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
              end
            end
            conditions.include?(true)
          end
          families.map(&:id)
        else
          family_ids = Family.includes(assessments: :assessment_domains).map do |family|
            next if family.assessments.customs.blank?
            assessment = family.assessments.customs.includes(:assessment_domains).reject do |assessment|
              scores = assessment.assessment_domains.pluck(:score)
              conditions = []
              if operator == 'equal'
                scores.exclude?(@value.to_i)
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
                (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
              end
            end
            assessment.first.try(:family_id)
          end
          family_ids.compact
        end
      end
    end
  end
end
