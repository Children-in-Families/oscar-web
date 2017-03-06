class ClientAdvanceFilter
  def initialize(search_rules)
    @condition = search_rules[:condition]
    @query_rules = search_rules[:rules]
    @client = FilterConditions.new(Client.all)
    @display_fields = [] 
  end

  def client_queries
    @query_rules.each do |_id,rule|
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
    @client.display_fields = @display_fields.uniq
    result = @client.resource
  end
          
end