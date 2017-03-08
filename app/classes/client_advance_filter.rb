class ClientAdvanceFilter
  def initialize(search_rules, clients)
    @condition = search_rules[:condition]
    @query_rules = search_rules[:rules]
    @client = FilterConditions.new(clients)
    @display_fields = [:id, :slug, :first_name]
  end

  def client_queries
    @query_rules.each do |rule|
    
      if drop_list_associated_fields.include?(rule[:field].to_sym)
        case rule[:field]
        when 'case_type'
          case_type_query(@client.resource, rule[:operator], rule[:value])
        when 'agency_name'
          agency_query(@client.resource, rule[:operator], rule[:value])
        when 'family_id'
          family_id_query(@client.resource, rule[:operator], rule[:value])
        end
      elsif text_list_associated_fields.include?(rule[:field].to_sym)
        family_name_query(@client.resource, rule[:operator], rule[:value])
      # elsif number_list_associated_fields.include?(rule[:field].to_sym)
      #   case rule[:field]
      #   when 'age'
      #     age_query(@client.resource, rule[:operator], rule[:value])
      #   when 'family_id'
      #     family_id_query(@client.resource, rule[:operator], rule[:value])
      #   end
      else  

        @display_fields << rule[:field].to_sym
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

  def drop_list_associated_fields
    [:case_type, :agency_name, :family_id]
  end 

  def number_list_associated_fields
    [:age 
      # :family_name, :case_type, :placement_date, :agency_name
    ]
  end


  def text_list_associated_fields
    [:family_name]
  end

  def age_query(resource, operator, value)
    @client.resource.age_between(value[0], value[1])
  end

  def family_name_query(resource, operator, value)
    clients = resource.joins(:families)
    ids = []
    Case.active.most_recents.joins(:client).group_by(&:client_id).each do |key, c|
      ids << c.first.id
    end

    if operator == 'equal'
      clients = clients.where(families:{ name: value })
    elsif operator == 'not_equal'
      clients = clients.where.not(families:{ name: value })
    elsif operator == 'contains'
      clients = clients.where('families.name iLike ? ', "%#{value}%")
    elsif operator == 'not_contains'
      clients = clients.where.not('families.name iLike ? ', "%#{value}%")
    end
    @client.resource = clients.joins(:cases).where("cases.id IN (?)", ids).select("name as family_name")
  end

  def family_id_query(resource, operator, value)
    ids = []
    Case.active.most_recents.joins(:client).group_by(&:client_id).each do |key, c|
      ids << c.first.id
    end
    @client.resource.joins(:cases).where("cases.id IN (?)", ids).where("cases.family_id = ? ", value) if value.present?
  end

  def case_type_query(resource, operator, value)
    case_ids = []
    resource.joins(:cases).where(cases: { exited: false }).each do |c|
      case_ids << c.cases.current.id
    end

    if operator == 'equal'
      @client.resource = resource.joins(:cases).where(cases: { id: case_ids, case_type: value }).select(:case_type)
    else
      @client.resource = resource.joins(:cases).where.not(cases: { id: case_ids, case_type: value }).select(:case_type)
    end
  end

  def agency_query(resource, operator, value)
    if operator == 'equal'
      @client.resource = resource.joins(:agencies).where(agencies: { id: value }).select("name as agency_name")
    else
      @client.resource = resource.joins(:agencies).where.not(agencies: { id: value }).select("name as agency_name")
    end
  end
end