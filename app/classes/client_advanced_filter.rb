class ClientAdvancedFilter
  DROP_LIST_ASSOCIATED_FIELDS   = [:case_type, :agency_name]
  DATE_LIST_ASSOCIATED_FIELDS   = [:placement_date]
  TEXT_LIST_ASSOCIATED_FIELDS   = [:family_name]
  NUMBER_LIST_ASSOCIATED_FIELDS = [:age, :family_id]

  def initialize(search_rules, clients)
    @condition = search_rules[:condition]
    @query_rules = search_rules[:rules]
    @client = BaseFilters.new(clients)
    @display_fields = [:id, :slug, :first_name]
  end

  def filter_by_field
    @query_rules.each do |rule|
      if DROP_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        case rule[:field]
        when 'case_type'
          case_type_field_query(@client.resource, rule[:operator], rule[:value])
        when 'agency_name'
          agency_field_query(@client.resource, rule[:operator], rule[:value])
        end
      elsif NUMBER_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        case rule[:field]
        when 'family_id'
          family_id_field_query(@client.resource, rule[:operator], rule[:value])
        when 'age'
          age_field_query(@client.resource, rule[:operator], rule[:value])
        end
      elsif TEXT_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        family_name_field_query(@client.resource, rule[:operator], rule[:value])
      elsif DATE_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        placement_date_field_query(@client.resource, rule[:operator], rule[:value])
      else 
        @display_fields << rule[:field]
        case rule[:operator]
        when 'equal'
          @client.is(rule[:field], rule[:value])  
        when 'not_equal'
          @client.is_not(rule[:field], rule[:value])  
        when 'less'
          @client.less(rule[:field], rule[:value])  
        when 'less_or_equal'
          @client.less_or_equal(rule[:field], rule[:value])      
        when 'greater'
          @client.greater(rule[:field], rule[:value])  
        when 'greater_or_equal'
          @client.greater_or_equal(rule[:field], rule[:value])  
        when 'between'
          @client.range_between(rule[:field], rule[:value])  
        when 'contains'
          @client.contains(rule[:field], rule[:value])  
        when 'not_contains'
          @client.not_contains(rule[:field], rule[:value])
        end
      end
    end
    @client.resource.select(@display_fields)
  end
    
  private

  def placement_date_field_query(resource, operator, value)
    clients = resource.joins(:cases)
    case operator
    when 'equal'
      clients = clients.where(cases: { start_date: value })
    when 'not_equal'
      clients = clients.where.not(cases: { start_date: value })
    when 'less'
      clients = clients.where('cases.start_date < ?', value)
    when 'less_or_equal'
      clients = clients.where('cases.start_date <= ?', value) 
    when 'greater'
      clients = clients.where('cases.start_date > ?', value) 
    when 'greater_or_equal'
      clients = clients.where('cases.start_date >= ?', value) 
    when 'between'
      clients = clients.where(cases: { start_date: value[0]..value[1] })
    end
    @client.resource = clients.uniq
  end

  def family_id_field_query(resource, operator, value)
    ids = Case.active.most_recents.joins(:client).group_by(&:client_id).map{|_k, c| c.first.id}
    clients = resource.joins(:cases).where("cases.id IN (?)", ids)

    case operator
    when 'equal'
      clients = clients.where("cases.family_id = ? ", value)
    when 'not_equal'
      clients = clients.where.not("cases.family_id = ? ", value)
    when 'less'
      clients = clients.where('cases.family_id < ?', value)
    when 'less_or_equal'
      clients = clients.where('cases.family_id <= ?', value) 
    when 'greater'
      clients = clients.where('cases.family_id > ?', value) 
    when 'greater_or_equal'
      clients = clients.where('cases.family_id >= ?', value) 
    when 'between'
      clients = clients.where(cases: { family_id: value[0]..value[1] })
    end
    @client.resource = clients.joins(:families).select('families.id as family_id')
  end

  def age_field_query(resource, operator, value)
    values = convert_age_to_date(value)

    case operator
    when 'equal'
      clients = resource.where(date_of_birth: values[0]..values[1])
    when 'not_equal'
      clients = resource.where.not(date_of_birth: values[0]..values[1])
    when 'less'
      clients = resource.where('date_of_birth > ?', values[0])
    when 'less_or_equal'
      clients = resource.where('date_of_birth >= ?', values[0])
    when 'greater'
      clients = resource.where('date_of_birth < ?', values[0])
    when 'greater_or_equal'
      clients = resource.where('date_of_birth <= ?', values[0])
    when 'between'
      clients = resource.where(date_of_birth: values[0]..values[1])
    end
    @client.resource = clients
    @display_fields << 'clients.date_of_birth'
  end

  def family_name_field_query(resource, operator, value)
    ids = Case.active.most_recents.joins(:client).group_by(&:client_id).map{ |_k, c| c.first.id }
    clients = resource.joins(:families)

    case operator
    when 'equal'
      clients = clients.where(families:{ name: value })
    when 'not_equal'
      clients = clients.where.not(families:{ name: value })
    when 'contains'
      clients = clients.where('families.name iLike ? ', "%#{value}%")
    when 'not_contains'
      clients = clients.where.not('families.name iLike ? ', "%#{value}%")
    end
    @client.resource = clients.joins(:cases).where("cases.id IN (?)", ids).select('families.name as family_name')
  end

  def case_type_field_query(resource, operator, value)
    case_ids = Client.joins(:cases).where(cases: { exited: false }).map{|c| c.cases.current.id}

    if operator == 'equal'
      @client.resource = resource.joins(:cases).where(cases: { id: case_ids, case_type: value }).select('cases.case_type as case_type')
    else
      @client.resource = resource.joins(:cases).where.not(cases: { id: case_ids, case_type: value }).select('cases.case_type as case_type')
    end
  end

  def agency_field_query(resource, operator, value)
    if operator == 'equal'
      @client.resource = resource.joins(:agencies).where(agencies: { id: value }).select('agencies.name as agencies_name')
    else
      @client.resource = resource.joins(:agencies).where.not(agencies: { id: value }).select('agencies.name as agencies_name')
    end
  end

  def convert_age_to_date(value)
    if value.is_a?(Array)
      [value[1].to_i.year.ago.to_date.beginning_of_month, value[0].to_i.year.ago.to_date.end_of_month]
    else
      date = value.to_i.year.ago.to_date
      [date.beginning_of_month, date.end_of_month]
    end
  end
end