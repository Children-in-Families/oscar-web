module AdvancedSearches
  class DomainScoreSqlBuilder

    def initialize(field, rule, basic_rule)
      @form_builder = field != nil ? field.split('__') : []
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
      when 'all_domains' || 'all_custom_domains'
        values = all_domains_query
      end
      { id: sql_string, values: values }
    end

    def domainscore_field_query
      assessments       = []

      if @basic_rules.second.present? && @basic_rules.second['id'] == 'assessment_number'
        between_date_value= @basic_rules.third['value']
        assessment_number = @basic_rules.second['value']
        clients = Client.joins(:assessments).all.each do |client|
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date_from           = between_date_value[0].to_date
          date_to             = between_date_value[1].to_date
          next unless dates[assessment_number.to_i-1].present?
          next unless dates[assessment_number.to_i-1].to_date >= date_from && dates[assessment_number.to_i-1].to_date <= date_to

          date                = dates[assessment_number.to_i-1].to_date
          number_assessments  = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          assessments         << number_assessments.first.id
        end
        assessment_filter_domainscore_query(assessments.flatten)
      elsif @basic_rules.second.present? && @basic_rules.second['id'] == 'month_number'
        between_date_value= @basic_rules.third['value']
        month_number = @basic_rules.second['value']
        clients = Client.includes(:assessments).all.each do |client|
          next if client.assessments.blank?
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date_from           = between_date_value[0].to_date
          date_to             = between_date_value[1].to_date
          next unless dates.uniq[month_number.to_i-1].present?
          next unless dates.uniq[assessment_number.to_i-1].to_date >= date_from && dates.uniq[assessment_number.to_i-1].to_date <= date_to

          date                = dates.uniq[month_number.to_i-1]
          month_assessments   = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          assessments        << month_assessments.ids
        end
        assessment_filter_domainscore_query(assessments.flatten)
      elsif @basic_rules.second.present? && @basic_rules.second['id'] == 'assessment_completed'
        score_change_query
      else
        only_domainscore_field_query
      end
    end

    def score_change_query
      return if @value.first == @value.last
      client_ids = []
      between_date_value = @basic_rules.second['value']

      case @operator
      when 'assessment_has_changed'
        Client.includes(:assessments).distinct.each do |client|
          next if (client.assessments.blank? || client.assessments.count < @value.last.to_i)
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date_from           = between_date_value[0].to_date
          date_to             = between_date_value[1].to_date
          next unless dates[@value.first.to_i-1].present? && dates[@value.last.to_i-1].present?
          next unless (dates[@value.first.to_i-1].to_date >= date_from && dates[@value.last.to_i-1].to_date <= date_to)

          date                = dates.uniq[@value.last.to_i-1]
          number_assessments  = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          number_assessments  = number_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score != assessment_domains.score", @domain_id) if number_assessments.present?
          client_ids          << client.id if number_assessments.present?
        end
      when 'assessment_has_not_changed'
        Client.includes(:assessments).distinct.each do |client|
          next if (client.assessments.blank? || client.assessments.count < @value.last.to_i)
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date_from           = between_date_value[0].to_date
          date_to             = between_date_value[1].to_date
          next unless dates[@value.first.to_i-1].present? && dates[@value.last.to_i-1].present?
          next unless (dates[@value.first.to_i-1].to_date >= date_from && dates[@value.last.to_i-1].to_date <= date_to)

          date                = dates.uniq[@value.last.to_i-1]
          number_assessments  = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          number_assessments  = number_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND (assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score)", @domain_id) if number_assessments.present?
          client_ids          << client.id if number_assessments.present?
        end
      when 'month_has_changed'
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients.all.each do |client|
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date_from           = between_date_value[0].to_date
          date_to             = between_date_value[1].to_date
          next unless dates.uniq[@value.first.to_i-1].present? && dates.uniq[@value.last.to_i-1].present?
          next unless (dates.uniq[@value.first.to_i-1].to_date >= date_from && dates.uniq[@value.last.to_i-1].to_date <= date_to)

          date                = dates.uniq[@value.last.to_i-1]
          month_assessments   = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score != assessment_domains.score", @domain_id) if month_assessments.present?
          client_ids          << client.id if month_assessments.present?
        end
      when 'month_has_not_changed'
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients.all.each do |client|
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date_from           = between_date_value[0].to_date
          date_to             = between_date_value[1].to_date
          next unless dates.uniq[@value.first.to_i-1].present? && dates.uniq[@value.last.to_i-1].present?
          next unless (date_from >= dates.uniq[@value.first.to_i-1].to_date && dates.uniq[@value.last.to_i-1].to_date <= date_to)

          date                = dates.uniq[@value.last.to_i-1]
          month_assessments   = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND (assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score)", @domain_id) if month_assessments.present?
          client_ids          << client.id if month_assessments.present?
        end
      end
      return client_ids.uniq
    end

    def assessment_filter_domainscore_query(assessments)
      client_ids = []

      case @operator
      when 'equal'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where(domain_id: @domain_id, score: @value)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'not_equal'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score != ?', @domain_id, @value)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'less'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score < ?', @domain_id, @value)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'less_or_equal'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score <= ?', @domain_id, @value)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'greater'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score > ?', @domain_id, @value)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'greater_or_equal'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score >= ?', @domain_id, @value)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'is_empty'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score = nil', @domain_id)
          client_ids << assessment.client_id if ass_domain.present?
        end
      when 'is_not_empty'
        assessments.compact.uniq.each do |id|
          assessment = Assessment.find_by(id: id)
          ass_domain = assessment.assessment_domains.where('domain_id = ? and score != nil', @domain_id)
          client_ids << assessment.client_id if ass_domain.present?
        end
      end

      return client_ids.uniq
    end

    def only_domainscore_field_query
      assessments = Assessment.joins([:assessment_domains, :client])

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
        client_ids  = Client.where.not(id: assessments.distinct.pluck(:client_id)).ids
      when 'is_not_empty'
        assessments = assessments.where('assessment_domains.domain_id = ? and assessment_domains.score IS NOT NULL', @domain_id)
      when 'assessment_has_changed'
        return if @value.first == @value.last
        client_ids = []
        clients = Client.includes(:assessments).distinct.each do |client|
          next if (client.assessments.blank? || client.assessments.count < @value.last.to_i)
          limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1))
          assessment        = limit_assessments.last.assessment_domains.where('assessment_domains.domain_id = ? and assessment_domains.previous_score != assessment_domains.score', @domain_id) if limit_assessments.present?
          client_ids        << client.id if assessment.present?
        end
        return client_ids.flatten.uniq
      when 'assessment_has_not_changed'
        return if @value.first == @value.last
        client_ids = []
        clients = Client.includes(:assessments).distinct.each do |client|
          next if (client.assessments.blank? || client.assessments.count < @value.last.to_i)
          limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1))
          assessment        = limit_assessments.last.assessment_domains.where('assessment_domains.domain_id = ? and (assessment_domains.previous_score IS NULL or assessment_domains.previous_score = assessment_domains.score)', @domain_id) if limit_assessments.present?
          client_ids        << client.id if assessment.present?
        end
        return client_ids.flatten.uniq
      when 'month_has_changed'
        return if @value.first == @value.last
        client_ids = []
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients = clients.all.each do |client|
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date                = dates.uniq[@value.last.to_i-1]
          month_assessments   = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND assessment_domains.previous_score != assessment_domains.score", @domain_id) if month_assessments.present?
          client_ids << client.id if month_assessments.present?
        end
        return client_ids.flatten.uniq
      when 'month_has_not_changed'
        return if @value.first == @value.last
        client_ids = []
        clients = Client.joins(:assessments).group(:id).having('COUNT(assessments) > 1')
        clients = clients.all.each do |client|
          ordered_assessments = client.assessments.order(:created_at)
          dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          date                = dates.uniq[@value.last.to_i-1]
          month_assessments   = client.assessments.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?
          month_assessments   = month_assessments.joins(:assessment_domains).where("assessment_domains.domain_id = ? AND (assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score)", @domain_id) if month_assessments.present?
          client_ids << client.id if month_assessments.present?
        end
        return client_ids.flatten.uniq
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
              (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
            end
          end
          clients.map(&:id)
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          clients = Client.joins(assessments: :assessment_domains).reject do |client|
            month_number_value  = get_month_assessment_number('month_number')
            ordered_assessments = client.assessments.defaults.order(:created_at)
            dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
            date                = dates.uniq[month_number_value-1]
            assessments         = client.assessments.defaults.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?

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
                conditions << true if (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
              end
            end
            conditions.include?(true)
          end
          clients.map(&:id).uniq
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
                (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
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
              (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
            end
          end
          clients.map(&:id)
        elsif @basic_rules.flatten.any?{|rule| rule['field'] == 'month_number'}
          clients = Client.joins(assessments: :assessment_domains).reject do |client|
            month_number_value  = get_month_assessment_number('month_number')
            ordered_assessments = client.assessments.customs.order(:created_at)
            dates               = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
            date                = dates.uniq[month_number_value-1]
            assessments         = client.assessments.customs.where("DATE(assessments.created_at) between ? AND ?", date.to_date.beginning_of_month, date.to_date.end_of_month) if date.present?

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
                conditions << true if (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
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
                (scores.compact.sum.to_f / assessment.assessment_domains.size.to_f).round != @value.to_i
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
