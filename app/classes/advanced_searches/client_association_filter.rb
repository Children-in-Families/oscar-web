module AdvancedSearches
  class ClientAssociationFilter
    include ActionView::Helpers::DateHelper
    include AssessmentHelper
    include FormBuilderHelper
    include ClientsHelper
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
        values = date_of_assessments_query(true)
      when /assessment_completed|assessment_completed_date/
        values = date_of_completed_assessments_query(nil)
      when 'date_of_custom_assessments'
        values = date_of_assessments_query(false)
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
      when 'time_in_cps'
        values = time_in_cps_query
      when 'time_in_ngo'
        values = time_in_ngo_query
      when 'assessment_number'
        values = assessment_number_query
      when 'month_number'
        values = month_number_query
      when 'date_nearest'
        values = date_nearest_query
      when 'date_of_referral'
        values = date_of_referral_query
      when 'referee_name'
        values = referee_name_query
      when 'referee_phone'
        values = referee_phone_query
      when 'referee_email'
        values = referee_email_query
      when 'carer_name'
        values = carer_name_query
      when 'carer_phone'
        values = carer_phone_query
      when 'carer_email'
        values = carer_email_query
      when 'client_contact_phone'
        values = client_contact_phone_query
      when 'client_email_address'
        values = client_email_address_query
      when 'phone_owner'
        values = phone_owner_query
      when 'referee_relationship'
        values = referee_relationship_query
      when /protection_concern_id|necessity_id/
        values = protection_concern_and_necessity(@field)
      end
      { id: sql_string, values: values }
    end

    private

    def date_of_referral_query
      clients = @clients.joins(:referrals).distinct
      case @operator
      when 'equal'
        clients = clients.where('date(referrals.date_of_referral) = ?', @value.to_date)
      when 'not_equal'
        clients = clients.where("date(referrals.date_of_referral) != ? OR referrals.date_of_referral IS NULL", @value.to_date)
      when 'less'
        clients = clients.where('date(referrals.date_of_referral) < ?', @value.to_date)
      when 'less_or_equal'
        clients = clients.where('date(referrals.date_of_referral) <= ?', @value.to_date)
      when 'greater'
        clients = clients.where('date(referrals.date_of_referral) > ?', @value.to_date)
      when 'greater_or_equal'
        clients = clients.where('date(referrals.date_of_referral) >= ?', @value.to_date)
      when 'between'
        clients = clients.where('date(referrals.date_of_referral) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
      when 'is_empty'
        clients = Client.includes(:referrals).where(referrals: { date_of_referral: nil })
      when 'is_not_empty'
        clients = clients.where.not(referrals: { date_of_referral: nil })
      end
      clients.ids
    end

    def assessment_number_query
      basic_rules = $param_rules['basic_rules']
      basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
      assessment_completed_sql, assessment_number = assessment_filter_values(results)
      sql = "(assessments.completed = true #{assessment_completed_sql}) AND ((SELECT COUNT(*) FROM assessments WHERE clients.id = assessments.client_id #{assessment_completed_sql}) >= #{@value})".squish
      @clients.joins(:assessments).where(sql).ids
    end

    def month_number_query
      if @value == 1
        clients = @clients.joins(:assessments).group(:id).having('COUNT(assessments) >= 1')
      else
        clients = @clients.joins(:assessments).distinct
        clients = clients.includes(:assessments).all.reject do |client|
          ordered_assessments = client.assessments.order(:created_at)
          dates = ordered_assessments.map(&:created_at).map{|date| date.strftime("%b, %Y") }
          dates = dates.uniq[@value-1]
          dates.nil?
        end
      end
      clients.map(&:id)
    end

    def date_nearest_query
      clients = @clients.joins(:assessments).where('date(assessments.created_at) <= ?', @value.to_date)
      clients.uniq.ids
    end

    def referred_to_query
      clients = @clients.joins(:referrals).distinct
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
      clients = @clients.joins(:referrals).distinct
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
      return [] if $param_rules.nil?
      basic_rules = $param_rules['basic_rules']
      basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      case_worker_rules = mapping_service_param_value(basic_rules, 'user_id')
      case_worker_id = case_worker_rules.first.present? && case_worker_rules.first[0].has_key?('value') ? case_worker_rules.first[0]['value'] : nil
      if case_worker_id && @operator == 'equal'
        clients = @clients.joins(:versions, :case_worker_clients).where(case_worker_clients: { user_id: case_worker_id })
      else
        clients = @clients.joins(:versions)
      end

      user    = User.find(@value) if @value.present?

      client_ids = []
      none_event_create_client_ids = []
      case @operator
      when 'equal'
        if user.email == ENV['OSCAR_TEAM_EMAIL']
          client_ids = clients.where("versions.event = ? AND (versions.whodunnit = ? OR versions.whodunnit iLike ?)", 'create', @value, "%rotati%").distinct.ids
          if client_ids.blank?
            client_ids = clients.group(:id).having("COUNT(versions) = (SELECT COUNT(*) FROM versions WHERE versions.item_type = ? AND versions.item_id = clients.id AND versions.event = ?)", 'Client', 'update').ids
          else
            none_event_create_client_ids = clients.group(:id).having("COUNT(versions) = (SELECT COUNT(*) FROM versions WHERE versions.item_type = ? AND versions.item_id = clients.id AND versions.event = ?)", 'Client', 'update').ids
          end
          return (client_ids + none_event_create_client_ids)
        else
          client_ids = clients.where("versions.event = ? AND versions.whodunnit = ?", 'create', @value).ids
        end
      when 'not_equal'
        client_ids = clients.where("versions.event = ? AND versions.whodunnit != ?", 'create', @value).distinct.ids
      when 'is_empty'
        client_ids = []
      when 'is_not_empty'
        client_ids = clients.ids
      end
      client_ids
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
        client_ids = Client.includes(:exit_ngos).where(exit_ngos: { id: [exit_ngos.ids, nil] }).distinct.ids
        return client_ids
      when 'is_not_empty'
        exit_ngos = exit_ngos.where.not("(exit_reasons = '{}')")
      end

      @clients.joins(:exit_ngos).where(exit_ngos: { id: exit_ngos.ids }).distinct.ids
    end

    def exit_ngo_exit_circumstance_query
      clients = @clients.joins(:exit_ngos)
      case @operator
      when 'equal'
        clients = clients.where(exit_ngos: { exit_circumstance: @value.squish })
      when 'not_equal'
        clients = clients.where.not(exit_ngos: { exit_circumstance: @value.squish })
      when 'is_empty'
        clients = Client.includes(:exit_ngos).where(exit_ngos: { exit_circumstance: ['', nil] })
      when 'is_not_empty'
        clients = clients.where.not(exit_ngos: { exit_circumstance: '' })
      end
      clients.distinct.ids
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
        ids = Client.includes(:exit_ngos).where(exit_ngos: { exit_date: nil }).distinct.ids
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
        ids = Client.includes(:enter_ngos).where(enter_ngos: { accepted_date: nil }).distinct.ids
        # clients haven't been accepted
        ids = ids << @clients.where.not(id: clients.distinct.ids).ids
        clients = @clients.where(id: ids.flatten.uniq)
      when 'is_not_empty'
        clients = clients.where.not(enter_ngos: { accepted_date: nil })
      end
      clients.ids
    end

    def date_of_assessments_query(type)
      if type.nil?
        clients = @clients.joins(:assessments)
      else
        clients = @clients.joins(:assessments).where(assessments: { default: type })
      end
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
        clients = Client.includes(:assessments).where(assessments: { created_at: nil })
      when 'is_not_empty'
        clients = clients.where.not(assessments: { created_at: nil })
      end
      clients.ids
    end

    def date_of_completed_assessments_query(type)
      if type.nil?
        clients = @clients.joins(:assessments).where(assessments: { completed: true })
      else
        clients = @clients.joins(:assessments).where(assessments: { completed: true, default: type })
      end
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
        clients = Client.includes(:assessments).where(assessments: { completed: true, created_at: nil })
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

      @basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      basic_rules   = @basic_rules.is_a?(Hash) ? @basic_rules : JSON.parse(@basic_rules).with_indifferent_access
      results       = mapping_allowed_param_value(basic_rules, ['case_note_date', 'case_note_type'], data_mapping=[])
      query_string  = get_any_query_string(results, 'case_notes')
      sql           = query_string.reject(&:blank?).map{|query| "(#{query})" }.join(" #{basic_rules[:condition]} ")
      clients       = Client.joins('LEFT OUTER JOIN case_notes ON case_notes.client_id = clients.id')
      client_ids    = clients.where(sql).ids
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

      basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      return object if basic_rules.nil?
      basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results      = mapping_form_builder_param_value(basic_rules, 'active_program_stream')
      query_string  = get_query_string(results, 'active_program_stream', 'program_streams')
      case @operator
      when 'not_equal'
        Client.includes(client_enrollments: :program_stream).where(query_string).references(:program_streams).distinct.ids
      when 'is_empty'
        Client.includes(client_enrollments: :program_stream).where(query_string).references(:program_streams).distinct.ids
      when 'is_not_empty'
        clients.joins(client_enrollments: :program_stream).distinct.ids
      else
        clients.includes(client_enrollments: :program_stream).where(program_streams: { id: @value }).references(:program_streams).distinct.ids
      end
    end

    def enrolled_program_stream_query
      clients = @clients.joins(:client_enrollments)
      case @operator
      when 'equal'
        clients.where('client_enrollments.program_stream_id = ?', @value ).distinct.ids
      when 'not_equal'
        #client_not_equal_ids = (clients.where('client_enrollments.program_stream_id != ?', @value ).distinct.ids + @clients.where.not(id: clients.distinct.ids).ids) - clients.where('client_enrollments.program_stream_id = ?', @value ).distinct.ids
        client_have_enrollments = clients.where('client_enrollments.program_stream_id = ?', @value ).distinct.ids
        client_not_enrollments = clients.where('client_enrollments.program_stream_id != ?', @value ).distinct.ids
        client_empty_enrollments = @clients.where.not(id: clients.distinct.ids).ids
        client_not_equal_ids = (client_not_enrollments+ client_empty_enrollments ) - client_have_enrollments
      when 'is_empty'
        @clients.where.not(id: clients.distinct.ids).ids
      when 'is_not_empty'
        clients.distinct.ids
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
        @clients.where.not(id: clients.distinct.ids).ids
      when 'is_not_empty'
        clients.distinct.ids
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
        @clients.where.not(id: clients.distinct.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def family_id_field_query
      values = validate_family_id(@value)
      case @operator
      when 'equal'
        client_ids = @clients.where(current_family_id: values).ids
      when 'not_equal'
        client_ids = @clients.where.not(current_family_id: values).ids
      when 'less'
        client_ids = @clients.where('clients.current_family_id < ?', values).ids
      when 'less_or_equal'
        client_ids = @clients.where('clients.current_family_id <= ?', values).ids
      when 'greater'
        client_ids = @clients.where('clients.current_family_id > ?', values).ids
      when 'greater_or_equal'
        client_ids = @clients.where('clients.current_family_id >= ?', values).ids
      when 'between'
        client_ids = @clients.where(current_family_id: values[0]..values[1]).ids
      when 'is_empty'
        client_ids = @clients.where(current_family_id: nil).ids
      when 'is_not_empty'
        client_ids = @clients.where.not(current_family_id: nil).ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def family_name_field_query
      case @operator
      when 'equal'
        client_ids = @clients.where("current_family_id = (SELECT id FROM families WHERE lower(families.name) = ?)", @value.downcase).ids
      when 'not_equal'
        client_ids = Client.where("clients.current_family_id != (SELECT id FROM families WHERE lower(families.name) = ?) OR clients.current_family_id IS NULL", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:families).where("lower(families.name) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:families).where("lower(families.name) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = Client.where("clients.current_family_id IS NULL").ids
      when 'is_not_empty'
        client_ids = Client.where("clients.current_family_id IS NOT NULL").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def user_id_field_query
      clients = @clients.joins(:case_worker_clients)
      ids = clients.distinct.ids
      case @operator
      when 'equal'
        client_ids = clients.where('case_worker_clients.user_id = ?', @value).distinct.ids
        client_ids & ids
      when 'not_equal'
        @clients.includes(:case_worker_clients).where('case_worker_clients.user_id != ? OR case_worker_clients.user_id IS NULL', @value).distinct.ids
      when 'is_empty'
        @clients.where.not(id: ids).ids
      when 'is_not_empty'
        @clients.where(id: ids).ids
      end
    end

    def time_in_cps_query
      client_ids = []
      clients = @clients.joins(:client_enrollments)
      # years_to_days = @value.kind_of?(Array) ? [@value.first * 365, @value.last * 365] : @value * 365 if @value.present?
      years_to_days = @value.kind_of?(Array) ? [@value.first, @value.last] : @value if @value.present?
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
        client_ids = @clients.where.not(id: clients.distinct.ids).ids
      when 'is_not_empty'
        client_ids = clients.distinct.ids
      end
      client_ids
    end

    def time_in_ngo_query
      client_ids = []
      clients = @clients.joins(:enter_ngos)
      # years_to_days = @value.kind_of?(Array) ? [@value.first * 365, @value.last * 365] : @value * 365 if @value.present?
      years_to_days =  @value.kind_of?(Array) ? [@value.first, @value.last] : @value if @value.present?
      case @operator
      when 'equal'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client) == years_to_days) }
      when 'not_equal'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client) != years_to_days) }
      when 'less'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client) < years_to_days ) }
      when 'less_or_equal'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client) <= years_to_days)  }
      when 'greater'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client) > years_to_days ) }
      when 'greater_or_equal'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client) >= years_to_days)  }
      when 'between'
        clients.each { |client| client_ids << client.id if (convert_time_in_ngo_to_days(client).present? && convert_time_in_ngo_to_days(client).between?(years_to_days.first, years_to_days.last)) }
      when 'is_empty'
        client_ids = @clients.where.not(id: clients.distinct.ids).ids
      when 'is_not_empty'
        client_ids = clients.distinct.ids
      end
      client_ids
    end

    def convert_time_in_care_to_days(client)
      if client.present? && client.time_in_cps.present?
        time_in_cps = client.time_in_cps
        days = 0
        time_in_cps.each do |cps|
          unless cps[1].blank?
            days += cps[1][:years] * 365 if (cps[1][:years].present? && cps[1][:years] > 0)
            days += cps[1][:months] * 30 if (cps[1][:months].present? && cps[1][:months] > 0)
            days += cps[1][:days]  if (cps[1][:months].present? && cps[1][:days] > 0)
          end
        end
        days
      end
    end

    def convert_time_in_ngo_to_days(client)
      if client.present? && client.time_in_ngo.present?
        time_in_ngo = client.time_in_ngo
        days = 0
        days += time_in_ngo[:years] * 365 if time_in_ngo[:years] > 0
        days += time_in_ngo[:months] * 30 if time_in_ngo[:months] > 0 && days.present?
        days += time_in_ngo[:days] if time_in_ngo[:days] > 0 && days.present?
        days
      end
    end

    def age_field_query
      date_value_format = convert_age_to_date(@value)
      case @operator
      when 'equal'
        # clients = @clients.where(date_of_birth: date_value_format.last_year.tomorrow..date_value_format)
        clients = @clients.where("(EXTRACT(year FROM age(current_date, date_of_birth)) :: int) = ?", @value)
      when 'not_equal'
        # clients = @clients.where.not(date_of_birth: date_value_format.last_year.tomorrow..date_value_format)
        clients = @clients.where("clients.date_of_birth is NULL OR (EXTRACT(year FROM age(current_date, date_of_birth)) :: int) != ?", @value)
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

    def referee_name_query
      case @operator
      when 'equal'
        client_ids = @clients.joins(:referee).where("lower(referees.name) = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.joins(:referee).where.not("lower(referees.name) = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:referee).where("lower(referees.name) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:referee).where("lower(referees.name) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.joins(:referee).where("referees.name = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.joins(:referee).where.not("referees.name = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def referee_phone_query
      case @operator
      when 'equal'
        client_ids = @clients.joins(:referee).where("lower(referees.phone) = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.joins(:referee).where.not("lower(referees.phone) = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:referee).where("lower(referees.phone) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:referee).where("lower(referees.phone) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.joins(:referee).where("referees.phone = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.joins(:referee).where.not("referees.phone = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def referee_email_query
      case @operator
      when 'equal'
        client_ids = @clients.joins(:referee).where("lower(referees.email) = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.joins(:referee).where.not("lower(referees.email) = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:referee).where("lower(referees.email) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:referee).where("lower(referees.email) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.joins(:referee).where("referees.email = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.joins(:referee).where.not("referees.email = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def carer_name_query
      case @operator
      when 'equal'
        client_ids = @clients.joins(:carer).where("lower(carers.name) = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.joins(:carer).where.not("lower(carers.name) = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:carer).where("lower(carers.name) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:carer).where("lower(carers.name) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.joins(:carer).where("carers.name = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.joins(:carer).where.not("carers.name = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def carer_phone_query
      case @operator
      when 'equal'
        client_ids = @clients.joins(:carer).where("lower(carers.phone) = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.joins(:carer).where.not("lower(carers.phone) = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:carer).where("lower(carers.phone) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:carer).where("lower(carers.phone) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.joins(:carer).where("carers.phone = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.joins(:carer).where.not("carers.phone = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def carer_email_query
      case @operator
      when 'equal'
        client_ids = @clients.joins(:carer).where("lower(carers.email) = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.joins(:carer).where.not("lower(carers.email) = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.joins(:carer).where("lower(carers.email) iLike ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.joins(:carer).where("lower(carers.email) NOT iLike ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.joins(:carer).where("carers.email = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.joins(:carer).where.not("carers.email = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def client_contact_phone_query
      case @operator
      when 'equal'
        client_ids = @clients.where("client_phone = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.where.not("client_phone = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.where("client_phone iLIKE ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.where("client_phone NOT iLIKE ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.where("client_phone = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.where.not("client_phone = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def client_email_address_query
      case @operator
      when 'equal'
        client_ids = @clients.where("client_email = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.where.not("client_email = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.where("client_email iLIKE ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.where("client_email NOT iLIKE ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.where("client_email = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.where.not("client_email = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def phone_owner_query
      case @operator
      when 'equal'
        client_ids = @clients.where("phone_owner = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.where.not("phone_owner = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.where("phone_owner iLIKE ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.where("phone_owner NOT iLIKE ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.where("phone_owner = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.where.not("phone_owner = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def referee_relationship_query
      case @operator
      when 'equal'
        client_ids = @clients.where("referee_relationship = ?", @value.downcase).ids
      when 'not_equal'
        client_ids = @clients.where.not("referee_relationship = ?", @value.downcase).ids
      when 'contains'
        client_ids = @clients.where("referee_relationship iLIKE ?", "%#{@value.downcase}%").ids
      when 'not_contains'
        client_ids = @clients.where("referee_relationship NOT iLIKE ?", "%#{@value.downcase}%").ids
      when 'is_empty'
        client_ids = @clients.where("referee_relationship = ?", "").ids
      when 'is_not_empty'
        client_ids = @clients.where.not("referee_relationship = ?", "").ids
      end

      clients = client_ids.present? ? client_ids : []
    end

    def protection_concern_and_necessity(field)
      basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      @basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access

      results      = mapping_allowed_param_value(@basic_rules, field)
      klass_name   = field == 'necessity_id' ? 'call_necessities' : 'call_protection_concerns'
      query_string = get_any_query_string(results, klass_name)
      sql          = query_string.reject(&:blank?).map{|query| "(#{query})" }.join(" #{@basic_rules[:condition]} ")

      client_ids = Client.includes(calls: klass_name.to_sym).where(sql).references(calls: klass_name.to_sym).distinct.ids
    end
  end
end
