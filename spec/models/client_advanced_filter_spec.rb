describe ClientAdvancedFilter, 'Method' do
  let!(:client)   { create(:client, first_name: 'pitou', code: 1000) }
  let!(:client_2) { create(:client, first_name: 'test1', code: 2000) }
  let!(:client_3) { create(:client, first_name: 'test2', code: 2010) }
  let!(:client_4) { create(:client, first_name: 'test3', code: 2020) }


  context '#filter_by_field with no association' do
    it 'return record with (is) condition' do
      filter_rules = { condition: "AND", rules: [{id: "first_name", field: "first_name", type: "string", input: "text", operator: "not_equal", value: "pitou"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 3
    end

    it 'return record with (is_not) condition' do
      filter_rules = { condition: "AND", rules: [{id: "first_name", field: "first_name", type: "string", input: "text", operator: "equal", value: "pitou"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 1
    end

    it 'return record with (not_contains) condition' do
      filter_rules = { condition: "AND", rules: [{id: "first_name", field: "first_name", type: "string", input: "text", operator: "contains", value: "ou"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 1
    end

    it 'return record with (contains) condition' do
      filter_rules = { condition: "AND", rules: [{id: "first_name", field: "first_name", type: "string", input: "text", operator: "not_contains", value: "ou"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 3
    end

    it 'return record with (less than) condition' do
      filter_rules = { condition: "AND", rules: [{id: "code", field: "code", type: "integer", input: "text", operator: "less", value: "2000"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 1
    end

    it 'return record with (less than or equal) condition' do
      filter_rules = { condition: "AND", rules: [{id: "code", field: "code", type: "integer", input: "text", operator: "less_or_equal", value: "2000"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 2
    end

    it 'return record with (greater than) condition' do
      filter_rules = { condition: "AND", rules: [{id: "code", field: "code", type: "integer", input: "text", operator: "greater", value: "2000"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 2
    end

    it 'return record with (greater than or equal) condition' do
      filter_rules = { condition: "AND", rules: [{id: "code", field: "code", type: "integer", input: "text", operator: "greater_or_equal", value: "2000"}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 3
    end

    it 'return record with (between) condition' do
      filter_rules = { condition: "AND", rules: [{id: "code", field: "code", type: "integer", input: "text", operator: "between", value: ['1000', '2020']}]}

      clients = ClientAdvancedFilter.new(filter_rules,  Client.all)
      clients = clients.filter_by_field
      expect(clients.size).to equal 4
    end
  end
end