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
      when 'placement_date'
        values = placement_date_field_query
      when 'form_title'
        values = form_title_field_query
      when 'case_type'
        values = case_type_field_query
      when 'agency_name'
        values = agency_name_field_query
      when 'family_id'
        values = family_id_field_query
      when 'family'
        values = family_name_field_query
      when 'age'
        values = age_field_query
      when 'referred_to_ec'
        values = program_placement_date_field_query('EC')
      when 'referred_to_fc'
        values = program_placement_date_field_query('FC')
      when 'referred_to_kc'
        values = program_placement_date_field_query('KC')
      when 'exit_ec_date'
        values = program_exit_date_field_query('EC')
      when 'exit_fc_date'
        values = program_exit_date_field_query('FC')
      when 'exit_kc_date'
        values = program_exit_date_field_query('KC')
      end
      {id: sql_string, values: values}
    end

    private

    def placement_date_field_query
      clients = @clients.joins(:cases)

      case @operator
      when 'equal'
        clients = clients.where(cases: { start_date: @value })
      when 'not_equal'
        clients = clients.where("cases.start_date != ? OR cases.start_date IS NULL", @value)
      when 'less'
        clients = clients.where('cases.start_date < ?', @value)
      when 'less_or_equal'
        clients = clients.where('cases.start_date <= ?', @value)
      when 'greater'
        clients = clients.where('cases.start_date > ?', @value)
      when 'greater_or_equal'
        clients = clients.where('cases.start_date >= ?', @value)
      when 'between'
        clients = clients.where(cases: { start_date: @value[0]..@value[1] })
      when 'is_empty'
        ids = @clients.where.not(id: clients.ids).ids
      end

      if @operator != 'is_empty'
        sub_query = 'SELECT MAX(cases.created_at) FROM cases WHERE cases.client_id = clients.id'
        ids = clients.where("cases.created_at = (#{sub_query})").ids
      end
      ids
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
      end
      clients.uniq.ids
    end

    def case_type_field_query
      clients = @clients.joins(:cases).where(cases: { exited: false })

      case @operator
      when 'equal'
        case_ids = clients.where(cases: { case_type: @value }).map { |c| c.cases.current.id if c.cases.current.case_type == @value }.uniq
        @clients.joins(:cases).where(cases: { id: case_ids }).ids
      when 'not_equal'
        case_ids = clients.where.not(cases: { case_type: @value }).map { |c| c.cases.current.id if c.cases.current.case_type != @value }.uniq
        @clients.joins(:cases).where(cases: { id: case_ids }).ids
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
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
      end
    end

    def family_id_field_query
      @values = validate_family_id(@value)
      sub_query = 'SELECT MAX(cases.created_at) FROM cases WHERE cases.exited = FALSE AND cases.client_id = clients.id'
      clients = @clients.joins(:families).joins(:cases).where("cases.created_at = (#{sub_query})")

      case @operator
      when 'equal'
        clients = clients.where('families.id = ? ', @values)
      when 'not_equal'
        clients = clients.where.not('families.id = ? ', @values)
      when 'less'
        clients = clients.where('families.id < ?', @values)
      when 'less_or_equal'
        clients = clients.where('families.id <= ?', @values)
      when 'greater'
        clients = clients.where('families.id > ?', @values)
      when 'greater_or_equal'
        clients = clients.where('families.id >= ?', @values)
      when 'between'
        clients = clients.where('families.id BETWEEN ? and ?', @values[0], @values[1])
      when 'is_empty'
        clients = @clients.where.not(id: clients.ids)
      end
      clients.ids.uniq
    end

    def family_name_field_query
      sub_query = 'SELECT MAX(cases.created_at) FROM cases WHERE cases.exited = FALSE AND cases.client_id = clients.id'
      clients = @clients.joins(:families).joins(:cases).where("cases.created_at = (#{sub_query})")

      case @operator
      when 'equal'
        clients  = clients.where('families.name = ?', @value)
      when 'not_equal'
        clients  = clients.where.not('families.name = ?', @value)
      when 'contains'
        clients  = clients.where('families.name ILIKE ?', "%#{@value}%")
      when 'not_contains'
        clients  = clients.where.not('families.name ILIKE ?', "%#{@value}%")
      when 'is_empty'
        clients = @clients.where.not(id: clients.ids)
      end
      clients.uniq.ids
    end

    def age_field_query
      date_format = convert_age_to_date(@value)
      case @operator
      when 'equal'
        clients = @clients.where(date_of_birth: date_format)
      when 'not_equal'
        clients = @clients.where.not(date_of_birth: date_format)
      when 'less'
        clients = @clients.where('date_of_birth > ?', date_format)
      when 'less_or_equal'
        clients = @clients.where('date_of_birth >= ?', date_format)
      when 'greater'
        clients = @clients.where('date_of_birth < ?', date_format)
      when 'greater_or_equal'
        clients = @clients.where('date_of_birth <= ?', date_format)
      when 'between'
        clients = @clients.where(date_of_birth: date_format[0]..date_format[1])
      when 'is_empty'
        clients = @clients.where('date_of_birth IS NULL')
      end
      clients.ids
    end

    def convert_age_to_date(value)
      overdue_year = 999.years.ago.to_date
      if value.is_a?(Array)
        min_age = (value[0].to_i * 12).months.ago.to_date
        max_age = (value[1].to_i * 12).months.ago.to_date
        min_age = min_age > overdue_year ? min_age : overdue_year
        max_age = max_age > overdue_year ? max_age : overdue_year
        [max_age, min_age]
      else
        age = (value.to_i * 12).months.ago.to_date
        age > overdue_year ? age : overdue_year
      end
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

    def program_placement_date_field_query(case_type)
      clients = @clients.joins(:cases)

      case @operator
      when 'equal'
        clients = clients.where(cases: { case_type: case_type, start_date: @value })
      when 'not_equal'
        clients = clients.where("cases.case_type = ? AND cases.start_date != ? OR cases.start_date IS NULL", case_type, @value)
      when 'less'
        clients = clients.where('cases.case_type = ? AND cases.start_date < ?', case_type, @value)
      when 'less_or_equal'
        clients = clients.where('cases.case_type = ? AND cases.start_date <= ?', case_type, @value)
      when 'greater'
        clients = clients.where('cases.case_type = ? AND cases.start_date > ?', case_type, @value)
      when 'greater_or_equal'
        clients = clients.where('cases.case_type = ? AND cases.start_date >= ?', case_type, @value)
      when 'between'
        clients = clients.where(cases: { case_type: case_type, start_date: @value[0]..@value[1] })
      when 'is_empty'
        ids = @clients.where.not(id: clients.ids).ids
      end

      if @operator != 'is_empty'
        ids = clients.ids
      end
      ids
    end

    def program_exit_date_field_query(case_type)
      clients = @clients.joins(:cases).where(cases: { exited: true })

      case @operator
      when 'equal'
        clients = clients.where(cases: { case_type: case_type, exit_date: @value })
      when 'not_equal'
        clients = clients.where("cases.case_type = ? AND cases.exit_date != ?", case_type, @value)
      when 'less'
        clients = clients.where('cases.case_type = ? AND cases.exit_date < ?', case_type, @value)
      when 'less_or_equal'
        clients = clients.where('cases.case_type = ? AND cases.exit_date <= ?', case_type, @value)
      when 'greater'
        clients = clients.where('cases.case_type = ? AND cases.exit_date > ?', case_type, @value)
      when 'greater_or_equal'
        clients = clients.where('cases.case_type = ? AND cases.exit_date >= ?', case_type, @value)
      when 'between'
        clients = clients.where(cases: { case_type: case_type, exit_date: @value[0]..@value[1] })
      when 'is_empty'
        clients = @clients.includes(:cases).where('cases.exited = ? OR cases.id IS NULL', false)
      end
      clients.ids.uniq
    end
  end
end
