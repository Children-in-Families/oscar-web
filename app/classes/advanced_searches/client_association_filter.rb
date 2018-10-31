module AdvancedSearches
  class ClientAssociationFilter
    def initialize(clients, field, operator, values)
      @clients      = clients
      @field        = field
      @operator     = operator
      @value        = values
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      case @field
      when 'user_id'
        values = user_id_field_query
      when 'agency_name'
        values = agency_name_field_query
      when 'donor_name'
        values = donor_name_field_query
      when 'family_id'
        values = family_id_field_query
      when 'family'
        values = family_name_field_query
      when 'age'
        values = age_field_query
      when 'active_program_stream'
        values = active_program_stream_query
      when 'enrolled_program_stream'
        values = enrolled_program_stream_query
      when 'case_note_date'
        values = advanced_case_note_query
      when 'case_note_type'
        values = advanced_case_note_query
      when 'date_of_assessments'
        values = date_of_assessments_field_query
      when 'accepted_date'
        values = enter_ngo_accepted_date_query
      when 'exit_date'
        values = exit_ngo_exit_date_query
      when 'exit_note'
        values = exit_ngo_text_field_query('exit_note')
      when 'other_info_of_exit'
        values = exit_ngo_text_field_query('other_info_of_exit')
      when 'exit_circumstance'
        values = exit_ngo_exit_circumstance_query
      when 'exit_reasons'
        values = exit_ngo_exit_reasons_query
      when 'created_by'
        values = created_by_user_query
      when 'referred_to'
        values = referred_to_query
      when 'referred_from'
        values = referred_from_query
      when 'time_in_care'
        values = time_in_care_query
      end
      { id: sql_string, values: values }
    end

    private

    def referred_to_query
      clients = @clients.joins(:referrals)
      case @operator
      when 'equal'
        clients.where('referrals.referred_to = ?', @value).ids
      when 'not_equal'
        clients.where('referrals.referred_to != ?', @value).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def referred_from_query
      clients = @clients.joins(:referrals)
      case @operator
      when 'equal'
        clients.where('referrals.referred_from = ?', @value).ids
      when 'not_equal'
        clients.where('referrals.referred_from != ?', @value).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def created_by_user_query
      user    = ''
      clients = @clients.joins(:versions)
      user    = User.find(@value) if @value.present?
      client_ids = []
      case @operator
      when 'equal'
        if user.email == ENV['OSCAR_TEAM_EMAIL']
          ids = clients.where("versions.event = ?", 'create').distinct.ids
          client_ids << clients.where.not(id: ids).distinct.ids
          client_ids << clients.where("(versions.event = ? AND versions.whodunnit = ?) OR (versions.event = ? AND versions.whodunnit iLike ?)", 'create', @value, 'create', '%rotati%').distinct.ids
          client_ids.flatten.uniq
        else
          clients.where("versions.event = ? AND versions.whodunnit = ?", 'create', @value).ids
        end
      when 'not_equal'
        if user.email == ENV['OSCAR_TEAM_EMAIL']
          client_ids << clients.where("versions.event = ? AND versions.whodunnit != ?", 'create', @value).where.not("versions.event = ? AND versions.whodunnit iLike ?", 'create', '%rotati%').distinct.ids
          client_ids.flatten.uniq
        else
          clients.where("versions.event = ? AND versions.whodunnit != ?", 'create', @value).ids
        end
      when 'is_empty'
        []
      when 'is_not_empty'
        clients.ids
      end
    end

    def exit_ngo_exit_reasons_query
      exit_ngos = ExitNgo.all
      case @operator
      when 'equal'
        exit_ngos = exit_ngos.where('(? = ANY(exit_reasons))', @value.squish)
      when 'not_equal'
        exit_ngos = exit_ngos.where.not('? = ANY(exit_reasons)', @value.squish)
      when 'is_empty'
        exit_ngos = exit_ngos.where("(exit_reasons = '{}')")
      when 'is_not_empty'
        exit_ngos = exit_ngos.where.not("(exit_reasons = '{}')")
      end

      @clients.joins(:exit_ngos).where(exit_ngos: { id: exit_ngos.ids }).ids.uniq
    end

    def exit_ngo_exit_circumstance_query
      clients = @clients.joins(:exit_ngos)
      case @operator
      when 'equal'
        clients = clients.where(exit_ngos: { exit_circumstance: @value.squish })
      when 'not_equal'
        clients = clients.where.not(exit_ngos: { exit_circumstance: @value.squish })
      when 'is_empty'
        clients = clients.where(exit_ngos: { exit_circumstance: '' })
      when 'is_not_empty'
        clients = clients.where.not(exit_ngos: { exit_circumstance: '' })
      end
      clients.ids
    end

    def exit_ngo_text_field_query(field)
      exit_ngos = ExitNgo.all
      case @operator
      when 'equal'
        client_id  = exit_ngos.find_by("lower(#{field}) = ?", @value.downcase.squish).try(:client_id)
        client_ids = Array(client_id)
      when 'not_equal'
        client_ids = exit_ngos.where.not("lower(#{field}) = ?", @value.downcase.squish).pluck(:client_id)
      when 'contains'
        client_ids = exit_ngos.where("#{field} ILIKE ?", "%#{@value.squish}%").pluck(:client_id)
      when 'not_contains'
        client_ids = exit_ngos.where.not("#{field} ILIKE ?", "%#{@value.squish}%").pluck(:client_id)
      when 'is_empty'
        client_ids = exit_ngos.where("#{field} = ?", '').pluck(:client_id)
      when 'is_not_empty'
        client_ids = exit_ngos.where.not("#{field} = ?", '').pluck(:client_id)
      end

      client_ids.present? ? @clients.joins(:exit_ngos).where(id: client_ids.flatten.uniq).ids : []
    end

    def exit_ngo_exit_date_query
      clients = @clients.joins(:exit_ngos)
      case @operator
      when 'equal'
        clients = clients.where(exit_ngos: { exit_date: @value.squish })
      when 'not_equal'
        clients = clients.where("exit_ngos.exit_date != ? OR exit_ngos.exit_date IS NULL", @value.squish)
      when 'less'
        clients = clients.where('exit_ngos.exit_date < ?', @value)
      when 'less_or_equal'
        clients = clients.where('exit_ngos.exit_date <= ?', @value)
      when 'greater'
        clients = clients.where('exit_ngos.exit_date > ?', @value)
      when 'greater_or_equal'
        clients = clients.where('exit_ngos.exit_date >= ?', @value)
      when 'between'
        clients = clients.where(exit_ngos: { exit_date: @value[0]..@value[1] })
      when 'is_empty'
        # clients have been exited but exit_date is blank
        ids = clients.where(exit_ngos: { exit_date: nil }).ids.uniq
        # clients haven't been exited
        ids = ids << @clients.where.not(id: clients.ids).ids
        clients = @clients.where(id: ids.flatten.uniq)
      when 'is_not_empty'
        clients = clients.where.not(exit_ngos: { exit_date: nil })
      end
      clients.ids
    end

    def enter_ngo_accepted_date_query
      clients = @clients.joins(:enter_ngos)
      case @operator
      when 'equal'
        clients = clients.where(enter_ngos: { accepted_date: @value })
      when 'not_equal'
        clients = clients.where("enter_ngos.accepted_date != ? OR enter_ngos.accepted_date IS NULL", @value)
      when 'less'
        clients = clients.where('enter_ngos.accepted_date < ?', @value)
      when 'less_or_equal'
        clients = clients.where('enter_ngos.accepted_date <= ?', @value)
      when 'greater'
        clients = clients.where('enter_ngos.accepted_date > ?', @value)
      when 'greater_or_equal'
        clients = clients.where('enter_ngos.accepted_date >= ?', @value)
      when 'between'
        clients = clients.where(enter_ngos: { accepted_date: @value[0]..@value[1] })
      when 'is_empty'
        # clients have been accepted but accepted_date is blank
        ids = clients.where(enter_ngos: { accepted_date: nil }).ids.uniq
        # clients haven't been accepted
        ids = ids << @clients.where.not(id: clients.ids).ids
        clients = @clients.where(id: ids.flatten.uniq)
      when 'is_not_empty'
        clients = clients.where.not(enter_ngos: { accepted_date: nil })
      end
      clients.ids
    end

    def date_of_assessments_field_query
      clients = @clients.joins(:assessments)
      case @operator
      when 'equal'
        clients = clients.where('date(assessments.created_at) = ?', @value.to_date)
      when 'not_equal'
        clients = clients.where("date(assessments.created_at) != ? OR assessments.created_at IS NULL", @value.to_date)
      when 'less'
        clients = clients.where('date(assessments.created_at) < ?', @value.to_date)
      when 'less_or_equal'
        clients = clients.where('date(assessments.created_at) <= ?', @value.to_date)
      when 'greater'
        clients = clients.where('date(assessments.created_at) > ?', @value.to_date)
      when 'greater_or_equal'
        clients = clients.where('date(assessments.created_at) >= ?', @value.to_date)
      when 'between'
        clients = clients.where('date(assessments.created_at) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
      when 'is_empty'
        clients = clients.where(assessments: { created_at: nil })
      when 'is_not_empty'
        clients = clients.where.not(assessments: { created_at: nil })
      end
      clients.ids
    end

    def case_note_type_field_query(basic_rules)
      param_values = []
      sql_string   = []
      rules        = basic_rules

      results      = case_note_basic_rules(rules, 'case_note_type')
      hashes       = mapping_query_result(results, 'case_note_type')

      hashes['case_note_type'].each do |rule|
        rule.keys.each do |key|
          values = rule[key]
          case key
          when 'equal'
            sql_string << "case_notes.interaction_type = ?"
            param_values << values.squish
          when 'not_equal'
            sql_string << "case_notes.interaction_type != ?"
            param_values << values.squish
          when 'is_empty'
            sql_string << "case_notes.interaction_type IS NULL"
            # param_values << ''
          when 'is_not_empty'
            sql_string << "case_notes.interaction_type IS NOT NULL"
          end
        end
      end
      sql_hash = { sql_string: sql_string, values: param_values }
    end

    def case_note_date_field_query(basic_rules)
      rules = basic_rules
      param_values = []
      sql_string   = []
      results = case_note_basic_rules(rules, 'case_note_date')
      hashes  = mapping_query_result(results, 'case_note_date')

      hashes.keys.each do |key|
        values   = hashes[key].flatten
        case key
        when 'between'
          sql_string << "date(case_notes.meeting_date) BETWEEN ? AND ?"
          param_values << values.first
          param_values << values.last
        when 'greater_or_equal'
          sql_string << "date(case_notes.meeting_date) >= ?"
          param_values << values
        when 'greater'
          sql_string << "date(case_notes.meeting_date) > ?"
          param_values << values
        when 'less'
          sql_string << "date(case_notes.meeting_date) < ?"
          param_values << values
        when 'less_or_equal'
          sql_string << "date(case_notes.meeting_date) <= ?"
          param_values << values
        when 'not_equal'
          sql_string << "date(case_notes.meeting_date) NOT IN (?)"
          param_values << values
        when 'equal'
          sql_string << "date(case_notes.meeting_date) IN (?)"
          param_values << values
        when 'is_empty'
          sql_string << "date(case_notes.meeting_date) IS NULL"
        when 'is_not_empty'
          sql_string << "date(case_notes.meeting_date) IS NOT NULL"
        end
      end

      { sql_string: sql_string, values: param_values }
    end

    def mapping_param_value(results, rule)
      results['rules'].reject{|h| h[:id] != rule }.map {|value| [value[:id], value[:operator], value[:value]] }
    end

    def mapping_query_result(results, field)
      hashes = {}
      if field == 'case_note_date'
        hashes  = values = Hash.new { |h,k| h[k] = []}
        results.each do |k, o, v|
          values[o] << v
          hashes[k] << values
        end

        hashes.keys.each do |value|
          arr = hashes[value]
          hashes.delete(value)
          hashes[value] << arr.uniq
        end
      else
        hashes       = Hash.new { |h,k| h[k] = []}
        results.each {|k, o, v| hashes[k] << {o => v} }
      end
      hashes
    end

    def advanced_case_note_query
      results = []
      case_note_date_query_array     = ['']
      case_note_type_query_array     = ['']
      sub_case_note_date_query_array = ['']
      sub_case_note_type_query_array = ['']

      @basic_rules  = $param_rules.present? ? $param_rules[:basic_rules] : {}
      return [] if @basic_rules.blank?
      basic_rules   = JSON.parse(@basic_rules)
      filter_values = basic_rules['rules']
      clients       = Client.joins(:case_notes)

      sub_rule_index = nil
      filter_values.each_with_index {|param, index| sub_rule_index = index if param.has_key?('condition')}

      if sub_rule_index.present?
        sub_case_note_date_sql_hash    = case_note_date_field_query(filter_values[sub_rule_index]['rules'])
        sub_case_note_type_sql_hash    = case_note_type_field_query(filter_values[sub_rule_index]['rules'])
        sub_case_note_date_query_array = mapping_query_string_with_query_value(sub_case_note_date_sql_hash, filter_values[sub_rule_index]['condition'])
        sub_case_note_type_query_array = mapping_query_string_with_query_value(sub_case_note_type_sql_hash, filter_values[sub_rule_index]['condition'])
      end

      case_note_date_sql_hash    = case_note_date_field_query(filter_values)
      case_note_type_sql_hash    = case_note_type_field_query(filter_values)
      case_note_date_query_array = mapping_query_string_with_query_value(case_note_date_sql_hash, basic_rules['condition'])
      case_note_type_query_array = mapping_query_string_with_query_value(case_note_type_sql_hash, basic_rules['condition'])

      if basic_rules['condition'] == 'AND'
        results = clients.where(case_note_date_query_array)
                         .where(sub_case_note_date_query_array)
                         .where(case_note_type_query_array)
                         .where(sub_case_note_type_query_array)
      else
        if sub_case_note_type_query_array.first.blank? && sub_case_note_date_query_array.first.blank?
          results = case_note_query_results(clients, case_note_date_query_array, case_note_type_query_array)
        elsif sub_case_note_date_query_array.first.present? && sub_case_note_type_query_array.first.blank?
          results = case_note_query_results(clients, case_note_date_query_array, case_note_type_query_array).or(clients.where(sub_case_note_date_query_array))
        elsif sub_case_note_type_query_array.first.present? && sub_case_note_date_query_array.first.blank?
          results = case_note_query_results(clients, case_note_date_query_array, case_note_type_query_array).or(clients.where(sub_case_note_type_query_array))
        else
          results = case_note_query_results(clients, case_note_date_query_array, case_note_type_query_array).or(clients.where(sub_case_note_type_query_array)).or(clients.where(sub_case_note_date_query_array))
        end
      end

      results.present? ? results.ids.uniq : []
    end

    def case_note_query_results(clients, case_note_date_query_array, case_note_type_query_array)
      results = []
      if case_note_date_query_array.first.present? && case_note_type_query_array.first.blank?
        results = clients.where(case_note_date_query_array)
      elsif case_note_date_query_array.first.blank? && case_note_type_query_array.first.present?
        results = clients.where(case_note_type_query_array)
      else
        results = clients.where(case_note_date_query_array).or(clients.where(case_note_type_query_array))
      end
      results
    end

    def case_note_basic_rules(basic_rules, field)
      basic_rules.reject{|h| h['id'] != field }.map {|value| [value['id'], value['operator'], value['value']] }
    end

    def mapping_query_string_with_query_value(sql_hash, operator)
      query_array = []
      query_array << sql_hash[:sql_string].join(" #{operator} ")
      sql_hash[:values].map{ |v| query_array << v }
      query_array
    end

    def active_program_stream_query
      clients = @clients.joins(:client_enrollments).where(client_enrollments: { status: 'Active' })
      case @operator
      when 'equal'
        clients.where('client_enrollments.program_stream_id = ?', @value).distinct.ids
      when 'not_equal'
        clients.where.not('client_enrollments.program_stream_id = ?', @value).distinct.ids
      when 'is_empty'
        clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        clients.where(id: clients.ids).ids
      end
    end

    def enrolled_program_stream_query
      clients = @clients.joins(:client_enrollments)
      case @operator
      when 'equal'
        clients.where('client_enrollments.program_stream_id = ?', @value ).distinct.ids
      when 'not_equal'
        clients.where.not('client_enrollments.program_stream_id = ?', @value ).distinct.ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def agency_name_field_query
      clients = @clients.joins(:agencies)
      case @operator
      when 'equal'
        clients.where('agencies.id = ?', @value ).ids
      when 'not_equal'
        clients.where.not('agencies.id = ?', @value ).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def donor_name_field_query
      clients = @clients.joins(:donors)
      case @operator
      when 'equal'
        clients.where('donors.id = ?', @value ).ids
      when 'not_equal'
        clients.where.not('donors.id = ?', @value ).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def family_id_field_query
      @values = validate_family_id(@value)
      families = Family.where.not("children = '{}' OR children is null")

      case @operator
      when 'equal'
        client_ids = families.find_by(id: @values).try(:children)
      when 'not_equal'
        client_ids = families.where.not(id: @values).pluck(:children)
      when 'less'
        client_ids = families.where('id < ?', @values).pluck(:children)
      when 'less_or_equal'
        client_ids = families.where('id <= ?', @values).pluck(:children)
      when 'greater'
        client_ids = families.where('id > ?', @values).pluck(:children)
      when 'greater_or_equal'
        client_ids = families.where('id >= ?', @values).pluck(:children)
      when 'between'
        client_ids = families.where(id: @values[0]..@values[1]).pluck(:children)
      when 'is_empty'
        client_ids = families.pluck(:children).flatten.uniq
        client_ids = @clients.where.not(id: client_ids).pluck(:id).uniq
      when 'is_not_empty'
        client_ids = families.pluck(:children).flatten.uniq
        client_ids = @clients.where(id: client_ids).pluck(:id).uniq
      end
      clients = client_ids.present? ? @clients.where(id: client_ids.flatten.uniq).ids : []
    end

    def family_name_field_query
      @values = validate_family_id(@value)
      families = Family.where.not("children = '{}' OR children is null").uniq

      case @operator
      when 'equal'
        client_ids = families.find_by('lower(name) = ?', @values.downcase).try(:children)
      when 'not_equal'
        client_ids = families.where.not('lower(name) = ?', @values.downcase).pluck(:children)
      when 'contains'
        client_ids = families.where('name ILIKE ?', "%#{@values.squish}%").pluck(:children)
      when 'not_contains'
        client_ids = families.where.not('name ILIKE ?', "%#{@values.squish}%").pluck(:children)
      when 'is_empty'
        client_ids = families.pluck(:children).flatten.uniq
        client_ids = @clients.where.not(id: client_ids).pluck(:id).uniq
      when 'is_not_empty'
        client_ids = families.pluck(:children).flatten.uniq
        client_ids = @clients.where(id: client_ids).pluck(:id).uniq
      end

      clients = client_ids.present? ? @clients.where(id: client_ids.flatten.uniq).ids : []
    end

    def user_id_field_query
      clients = @clients.joins(:users)
      ids = clients.ids.uniq
      case @operator
      when 'equal'
        client_ids = Client.joins(:users).where('users.id = ?', @value).ids
        client_ids & ids
      when 'not_equal'
        clients.where.not('users.id = ?', @value ).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def time_in_care_query
      client_ids = []
      clients = @clients.joins(:client_enrollments)
      years_to_days = @value.kind_of?(Array) ? [@value.first * 365, @value.last * 365] : @value * 365 if @value.present?
      case @operator
      when 'equal'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client) == years_to_days }
      when 'not_equal'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client) != years_to_days }
      when 'less'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client) < years_to_days  }
      when 'less_or_equal'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client) <= years_to_days  }
      when 'greater'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client) > years_to_days  }
      when 'greater_or_equal'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client) >= years_to_days  }
      when 'between'
        clients.each { |client| client_ids << client.id if convert_time_in_care_to_days(client).between?(years_to_days.first, years_to_days.last) }
      when 'is_empty'
        client_ids = @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        client_ids = clients.ids
      end
      client_ids
    end

    def convert_time_in_care_to_days(client)
      time_in_care = client.time_in_care
      days = 0
      days += time_in_care[:years] * 365 if time_in_care[:years] > 0
      days += time_in_care[:months] * 30 if time_in_care[:months] > 0
      days += time_in_care[:weeks] * 7 if time_in_care[:weeks] > 0
      days
    end

    def age_field_query
      date_value_format = convert_age_to_date(@value)
      case @operator
      when 'equal'
        clients = @clients.where(date_of_birth: date_value_format.last_year.tomorrow..date_value_format)
      when 'not_equal'
        clients = @clients.where.not(date_of_birth: date_value_format.last_year.tomorrow..date_value_format)
      when 'less'
        clients = @clients.where('date_of_birth > ?', date_value_format)
      when 'less_or_equal'
        clients = @clients.where('date_of_birth >= ?', date_value_format.last_year)
      when 'greater'
        clients = @clients.where('date_of_birth < ?', date_value_format.last_year)
      when 'greater_or_equal'
        clients = @clients.where('date_of_birth <= ?', date_value_format)
      when 'between'
        clients = @clients.where(date_of_birth: date_value_format[0]..date_value_format[1])
      when 'is_empty'
        clients = @clients.where('date_of_birth IS NULL')
      when 'is_not_empty'
        clients = @clients.where.not('date_of_birth IS NULL')
      end
      clients.ids
    end

    def validate_family_id(ids)
      if ids.is_a?(Array)
        first_value = ids.first.to_i > 1000000 ? "1000000" : ids.first
        last_value  = ids.last.to_i > 1000000 ? "1000000" : ids.last
        [first_value, last_value]
      else
        ids.to_i > 1000000 ? "1000000" : ids
      end
    end

    def convert_age_to_date(value)
      overdue_year = 999.years.ago.to_date
      if value.is_a?(Array)
        min_age = (value[0].to_i * 12).months.ago.to_date
        max_age = ((value[1].to_i + 1) * 12).months.ago.to_date.tomorrow
        min_age = min_age > overdue_year ? min_age : overdue_year
        max_age = max_age > overdue_year ? max_age : overdue_year
        [max_age, min_age]
      else
        age = (value.to_i * 12).months.ago.to_date
        age > overdue_year ? age : overdue_year
      end
    end
  end
end
