describe AdvancedSearches::ProgramExitDateSqlBuilder, 'Method' do
  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:client_enrollment)  { create(:client_enrollment, client: client, program_stream: program_stream) }
  let!(:leave_program)      { create(:leave_program, exit_date: Date.today, client_enrollment: client_enrollment, program_stream: program_stream)}

  context '#get_sql' do
    it 'return clients with operator (equal)' do
      rules = { 'operator'=> 'equal', 'value'=> Date.today.to_s }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_equal)' do
      rules = { 'operator'=> 'not_equal', 'value'=> 1.day.ago.to_s }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less)' do
      rules = { 'operator'=> 'less', 'value'=> Date.tomorrow.to_s }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less_or_equal)' do
      rules = { 'operator'=> 'less_or_equal', 'value'=> Date.today.to_s }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater)' do
      rules = { 'operator'=> 'greater', 'value'=> 1.day.ago.to_s }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater_or_equal)' do
      rules = { 'operator'=> 'greater_or_equal', 'value'=> Date.today.to_s }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (is_empty)' do
      rules = { 'operator'=> 'is_empty', 'value'=> '' }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include
    end

    it 'return clients with operator (is_not_empty)' do
      rules = { 'operator'=> 'is_not_empty', 'value'=> '' }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (between)' do
      rules = { 'operator'=> 'between', 'value'=> [1.day.ago.to_s,  Date.today.to_s] }
      client_filter = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end
  end
end