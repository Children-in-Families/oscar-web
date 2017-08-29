describe AdvancedSearches::EnrollmentSqlBuilder, 'Method' do
  properties = {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}

  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:client_enrollment)  { create(:client_enrollment, properties: properties.to_json, client: client, program_stream: program_stream) }

  context '#get_sql' do
    it 'return clients with operator (equal)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'equal', 'value'=> '3' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_equal)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'not_equal', 'value'=> '4' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'less', 'value'=> '4' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less_or_equal)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'less_or_equal', 'value'=> '4' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'greater', 'value'=> '2' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater_or_equal)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'greater_or_equal', 'value'=> '2' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (contains)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_description", 'operator'=> 'greater_or_equal', 'value'=> 'testing' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_contains)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_description", 'operator'=> 'greater_or_equal', 'value'=> 'name' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (is_empty)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'is_empty', 'value'=> '' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include
    end

    it 'return clients with operator (is_not_empty)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'is_not_empty', 'value'=> '' }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (between)' do
      rules = { 'field'=> "enrollment_#{program_stream.name}_age", 'operator'=> 'between', 'value'=> ['2', '4'] }
      client_filter = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end
  end
end
