describe AdvancedSearches::ClientBaseSqlBuilder, 'Method' do

  context '#generate' do
    it 'return client = query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"school_name", "field"=>"school_name", "type"=>"string", "input"=>"text", "operator"=>"equal", "value"=>"Pirun"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'lower(clients.school_name) = ?'
      expect(filter_string[:values]).to include 'pirun'
    end

    it 'return client != query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"school_name", "field"=>"school_name", "type"=>"string", "input"=>"text", "operator"=>"not_equal", "value"=>"Pirun"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'lower(clients.school_name) != ?'
      expect(filter_string[:values]).to include 'pirun'
    end

    it 'return client < query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"grade", "field"=>"grade", "type"=>"number", "input"=>"text", "operator"=>"less", "value"=>"12"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.grade < ?'
      expect(filter_string[:values]).to include '12'
    end

    it 'return client <= query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"grade", "field"=>"grade", "type"=>"number", "input"=>"text", "operator"=>"less_or_equal", "value"=>"12"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.grade <= ?'
      expect(filter_string[:values]).to include '12'
    end

    it 'return client > query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"grade", "field"=>"grade", "type"=>"number", "input"=>"text", "operator"=>"greater", "value"=>"12"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.grade > ?'
      expect(filter_string[:values]).to include '12'
    end

    it 'return client >= query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"grade", "field"=>"grade", "type"=>"number", "input"=>"text", "operator"=>"greater_or_equal", "value"=>"12"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.grade >= ?'
      expect(filter_string[:values]).to include '12'
    end

    it 'return client ILIKE query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"school_name", "field"=>"school_name", "type"=>"string", "input"=>"text", "operator"=>"contains", "value"=>"Pirun"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.school_name ILIKE ?'
      expect(filter_string[:values]).to include '%Pirun%'
    end

    it 'return client NOT ILIKE query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"school_name", "field"=>"school_name", "type"=>"string", "input"=>"text", "operator"=>"not_contains", "value"=>"Pirun"}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.school_name NOT ILIKE ?'
      expect(filter_string[:values]).to include '%Pirun%'
    end

    it 'return client IS NULL query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"school_name", "field"=>"school_name", "type"=>"string", "input"=>"text", "operator"=>"is_empty", "value"=>""}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.school_name IS NULL'
      expect(filter_string[:values]).to include
    end

    it 'return client BETWEEN query string' do
      rules = {"condition"=>"AND", "rules"=>[{"id"=>"grade", "field"=>"grade", "type"=>"number", "input"=>"text", "operator"=>"between",  "value"=>['0', '12']}]}
      filter_string = AdvancedSearches::ClientBaseSqlBuilder.new(Client.all, rules).generate
      expect(filter_string[:sql_string]).to include 'clients.grade BETWEEN ? AND ?'
      expect(filter_string[:values]).to include '0', '12'
    end
  end
end
