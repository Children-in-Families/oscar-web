class ClientAdvancedFilter
  NULL_TYPE = %w('date_of_birth initial_referral_date birth_province_id received_by_id followed_up_by_id follow_up_date province_id referral_source_id user_id donor_id')
  DROP_LIST_ASSOCIATED_FIELDS   = [:case_type, :agency_name, :form_title].freeze
  DATE_LIST_ASSOCIATED_FIELDS   = [:placement_date].freeze
  TEXT_LIST_ASSOCIATED_FIELDS   = [:family_name].freeze
  NUMBER_LIST_ASSOCIATED_FIELDS = [:age, :family_id].freeze

  def initialize(search_rules, clients)
    @client      = BaseFilters.new(clients)
    @condition   = search_rules[:condition]
    @query_rules = search_rules[:rules]
  end

  def filter_by_field
    @query_rules.each do |rule|
      if DROP_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        drop_list_associated_fields(rule)
      elsif NUMBER_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        number_list_associated_fields(rule)
      elsif TEXT_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        text_list_associated_fields(rule)
      elsif DATE_LIST_ASSOCIATED_FIELDS.include?(rule[:field].to_sym)
        date_list_associated_fields(rule)
      else
        base_filter_fields(rule)
      end
    end
    @client.resource
  end

  private

  def placement_date_field_query(resource, operator, value)
    clients = resource.joins(:cases)

    case operator
    when 'equal'
      clients = clients.where(cases: { start_date: value })
    when 'not_equal'
      clients = clients.where("cases.start_date != ? OR cases.start_date IS NULL", value)
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
    if operator == 'is_empty'
      client_ids = clients.ids
      @client.resource = resource.where.not(id: client_ids)
    else
      ids = clients.map { |c| c.cases.last.id }.uniq
      @client.resource = clients.where(cases: { id: ids })
    end
  end

  def family_id_field_query(resource, operator, value)
    ids     = Case.active.most_recents.joins(:client).group_by(&:client_id).map { |_k, c| c.first.id }
    clients = resource.joins(:families).joins(:cases).where('cases.id IN (?)', ids)
    case operator
    when 'equal'
      clients = clients.where('cases.family_id = ? ', value)
    when 'not_equal'
      clients = clients.where.not('cases.family_id = ? ', value)
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
    when 'is_empty'
      clients = resource.where.not(id: clients.ids)
    end
    @client.resource = clients.uniq
  end

  def family_name_field_query(resource, operator, value)
    ids     = Case.active.most_recents.joins(:client).group_by(&:client_id).map { |_k, c| c.first.id }
    clients = resource.joins(:families).joins(:cases).where(cases: { id: ids })
    case operator
    when 'equal'
      families = Family.where(name: value)
      clients  = clients.where(cases: { family_id: families })
    when 'not_equal'
      families = Family.where(name: value)
      clients  = clients.where.not(cases: { family_id: families })
    when 'contains'
      families = Family.where('name iLike ? ', "%#{value}%")
      clients  = clients.where(cases: { family_id: families })
    when 'not_contains'
      families = Family.where('name iLike ? ', "%#{value}%")
      clients = clients.where.not(cases: { family_id: families })
    when 'is_empty'
      clients = resource.where.not(id: clients.ids)
    end
    @client.resource = clients.uniq
  end

  def form_title_field_query(resource, operator, value)
    clients = resource.joins(:custom_fields)
    case operator
    when 'equal'
      clients = clients.where(custom_fields: { id: value })
    when 'not_equal'
      clients = clients.where.not(custom_fields: { id: value })
    when 'is_empty'
      clients = resource.where.not(id: clients.ids)
    end
    @client.resource = clients.uniq
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
    when 'is_empty'
      clients = resource.where('date_of_birth IS NULL')
    end
    @client.resource = clients
  end

  def case_type_field_query(resource, operator, value)
    clients = resource.joins(:cases).where(cases: { exited: false })
    case operator
    when 'equal'
      case_ids = clients.where(cases: { case_type: value }).map { |c| c.cases.current.id if c.cases.current.case_type == value }.uniq
      @client.resource = resource.joins(:cases).where(cases: { id: case_ids }).uniq
    when 'not_equal'
      case_ids = clients.where.not(cases: { case_type: value }).map { |c| c.cases.current.id if c.cases.current.case_type != value }.uniq
      @client.resource = resource.joins(:cases).where(cases: { id: case_ids }).uniq
    when 'is_empty'
      client_ids = clients.ids
      @client.resource = resource.where.not(id: client_ids)
    end
  end

  def agency_field_query(resource, operator, value)
    clients = resource.joins(:agencies)
    case operator
    when 'equal'
      clients = clients.where(agencies: { id: value })
      @client.resource = clients.uniq
    when 'not_equal'
      clients = clients.where.not(agencies: { id: value })
      @client.resource = clients.uniq
    when 'is_empty'
      client_ids = clients.uniq
      @client.resource = resource.where.not(id: client_ids)
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

  def drop_list_associated_fields(rule)
    case rule[:field]
    when 'case_type'
      case_type_field_query(@client.resource, rule[:operator], rule[:value])
    when 'agency_name'
      agency_field_query(@client.resource, rule[:operator], rule[:value])
    when 'form_title'
      form_title_field_query(@client.resource, rule[:operator], rule[:value])
    end
  end

  def number_list_associated_fields(rule)
    case rule[:field]
    when 'family_id'
      family_id_field_query(@client.resource, rule[:operator], rule[:value])
    when 'age'
      age_field_query(@client.resource, rule[:operator], rule[:value])
    end
  end

  def text_list_associated_fields(rule)
    family_name_field_query(@client.resource, rule[:operator], rule[:value])
  end

  def date_list_associated_fields(rule)
    placement_date_field_query(@client.resource, rule[:operator], rule[:value])
  end

  def base_filter_fields(rule)
    case rule[:operator]
    when 'equal'
      @client.is('clients', rule[:field], rule[:value])
    when 'not_equal'
      @client.is_not('clients', rule[:field], rule[:value])
    when 'less'
      @client.less('clients', rule[:field], rule[:value])
    when 'less_or_equal'
      @client.less_or_equal('clients', rule[:field], rule[:value])
    when 'greater'
      @client.greater('clients', rule[:field], rule[:value])
    when 'greater_or_equal'
      @client.greater_or_equal('clients', rule[:field], rule[:value])
    when 'between'
      @client.range_between('clients', rule[:field], rule[:value])
    when 'contains'
      @client.contains('clients', rule[:field], rule[:value])
    when 'not_contains'
      @client.not_contains('clients', rule[:field], rule[:value])
    when 'is_empty'
      null_type = NULL_TYPE.include? rule[:field]
      @client.is_empty('clients', rule[:field], null_type)
    end
  end

end
