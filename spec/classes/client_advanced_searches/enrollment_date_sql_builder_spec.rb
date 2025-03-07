describe AdvancedSearches::EnrollmentDateSqlBuilder, 'Method' do
  before do
    $param_rules = { "basic_rules" => {"condition"=>"AND",
                                       "rules"=>
                                         [{"id"=>"enrollmentdate__Program Stream__Enrollment Date",
                                           "field"=>"Enrollment Date",
                                           "type"=>"date",
                                           "input"=>"text",
                                           "operator"=>"equal",
                                           "value"=> Date.today.to_s }],
                                       "valid"=>true} }.with_indifferent_access

    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  let!(:basic_rule) {  $param_rules['basic_rules']['rules'][0] }
  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:client_enrollment)  { create(:client_enrollment, enrollment_date: Date.today, client: client, program_stream: program_stream) }

  context '#get_sql' do
    it 'return clients with operator (equal)' do
      rules = { 'operator'=> 'equal', 'value'=> Date.today.to_s }
      new_rules = basic_rule.merge(rules)
      basic_rules = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_equal)' do
      rules = { 'operator'=> 'not_equal', 'value'=> 1.day.ago.to_s }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less)' do
      rules = { 'operator'=> 'less', 'value'=> Date.tomorrow.to_s }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less_or_equal)' do
      rules = { 'operator'=> 'less_or_equal', 'value'=> Date.today.to_s }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater)' do
      rules = { 'operator'=> 'greater', 'value'=> 1.day.ago.to_s }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater_or_equal)' do
      rules = { 'operator'=> 'greater_or_equal', 'value'=> Date.today.to_s }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (is_empty)' do
      rules = { 'operator'=> 'is_empty', 'value'=> '' }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include
    end

    it 'return clients with operator (is_not_empty)' do
      rules = { 'operator'=> 'is_not_empty', 'value'=> '' }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (between)' do
      rules = { 'operator'=> 'between', 'value'=> [1.day.ago.to_s,  Date.today.to_s] }
      new_rules = basic_rule.merge(rules)
      $param_rules['basic_rules']['rules'][0] = new_rules
      client_filter = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end
  end
end