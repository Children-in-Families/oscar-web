module AdvancedSearches
  class ClientAssociationFilter
    def initialize(clients, field, operator, values)
      @clients  = clients
      @field    = field
      @operator = operator
      @value   = values
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      case @field
      when 'form_title'
        values = form_title_field_query
      when 'user_id'
        values = user_id_field_query
      when 'agency_name'
        values = agency_name_field_query
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
        values = case_note_date_field_query
      when 'case_note_type'
        values = case_note_type_field_query
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
      end
      { id: sql_string, values: values }
    end

    private

    def exit_ngo_exit_reasons_query
      exit_ngos = ExitNgo.all
      case @operator
      when 'equal'
        exit_ngos = exit_ngos.where('(? = ANY(exit_reasons))', @value)
      when 'not_equal'
        exit_ngos = exit_ngos.where.not('? = ANY(exit_reasons)', @value)
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
        clients = clients.where(exit_ngos: { exit_circumstance: @value })
      when 'not_equal'
        clients = clients.where.not(exit_ngos: { exit_circumstance: @value })
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
        client_id  = exit_ngos.find_by("lower(#{field}) = ?", @value.downcase).try(:client_id)
        client_ids = Array(client_id)
      when 'not_equal'
        client_ids = exit_ngos.where.not("lower(#{field}) = ?", @value.downcase).pluck(:client_id)
      when 'contains'
        client_ids = exit_ngos.where("#{field} ILIKE ?", "%#{@value}%").pluck(:client_id)
      when 'not_contains'
        client_ids = exit_ngos.where.not("#{field} ILIKE ?", "%#{@value}%").pluck(:client_id)
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
        clients = clients.where(exit_ngos: { exit_date: @value })
      when 'not_equal'
        clients = clients.where("exit_ngos.exit_date != ? OR exit_ngos.exit_date IS NULL", @value)
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

    def case_note_type_field_query
      clients = @clients.joins(:case_notes)
      case @operator
      when 'equal'
        clients = clients.where(case_notes: { interaction_type: @value })
      when 'not_equal'
        clients = clients.where.not(case_notes: { interaction_type: @value })
      when 'is_empty'
        clients = clients.where(case_notes: { interaction_type: '' })
      when 'is_not_empty'
        clients = clients.where.not(case_notes: { interaction_type: '' })
      end
      clients.ids
    end

    def case_note_date_field_query
      clients = @clients.joins(:case_notes)
      case @operator
      when 'equal'
        clients = clients.where(case_notes: { meeting_date: @value })
      when 'not_equal'
        clients = clients.where("case_notes.meeting_date != ? OR case_notes.meeting_date IS NULL", @value)
      when 'less'
        clients = clients.where('case_notes.meeting_date < ?', @value)
      when 'less_or_equal'
        clients = clients.where('case_notes.meeting_date <= ?', @value)
      when 'greater'
        clients = clients.where('case_notes.meeting_date > ?', @value)
      when 'greater_or_equal'
        clients = clients.where('case_notes.meeting_date >= ?', @value)
      when 'between'
        clients = clients.where(case_notes: { meeting_date: @value[0]..@value[1] })
      when 'is_empty'
        clients = clients.where(case_notes: { meeting_date: nil })
      when 'is_not_empty'
        clients = clients.where.not(case_notes: { meeting_date: nil })
      end
      clients.ids
    end

    def active_program_stream_query
      clients = @clients.joins(:client_enrollments).where(client_enrollments: { status: 'Active' })
      case @operator
      when 'equal'
        clients.where('client_enrollments.program_stream_id = ?', @value ).ids
      when 'not_equal'
        clients.where.not('client_enrollments.program_stream_id = ?', @value ).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def enrolled_program_stream_query
      clients = @clients.joins(:client_enrollments)
      case @operator
      when 'equal'
        clients.where('client_enrollments.program_stream_id = ?', @value ).ids
      when 'not_equal'
        clients.where.not('client_enrollments.program_stream_id = ?', @value ).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def form_title_field_query
      clients = @clients.joins(:custom_fields)
      case @operator
      when 'equal'
        clients = clients.where('custom_fields.id = ?', @value)
      when 'not_equal'
        clients = clients.where.not('custom_fields.id = ?', @value)
      when 'is_empty'
        clients = @clients.where.not(id: clients.ids)
      when 'is_not_empty'
        clients = @clients.where(id: clients.ids)
      end
      clients.uniq.ids
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
        client_ids = families.where('name ILIKE ?', "%#{@values}%").pluck(:children)
      when 'not_contains'
        client_ids = families.where.not('name ILIKE ?', "%#{@values}%").pluck(:children)
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
      case @operator
      when 'equal'
        clients.where('users.id = ?', @value ).ids
      when 'not_equal'
        clients.where.not('users.id = ?', @value ).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
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
