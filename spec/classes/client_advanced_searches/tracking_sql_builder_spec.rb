xdescribe AdvancedSearches::TrackingSqlBuilder, 'Method' do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  properties = {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}

  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:tracking)           { create(:tracking, program_stream: program_stream)}
  let!(:client_enrollment)  { create(:client_enrollment, client: client, program_stream: program_stream) }
  let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, properties: properties, client_enrollment: client_enrollment, tracking: tracking)}

  context '#get_sql' do
    it 'return clients with operator (equal)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'equal', 'value'=> '3' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_equal)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'not_equal', 'value'=> '4' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'less', 'value'=> '4' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (less_or_equal)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'less_or_equal', 'value'=> '4' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'greater', 'value'=> '2' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (greater_or_equal)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'greater_or_equal', 'value'=> '2' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (contains)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__description", 'operator'=> 'greater_or_equal', 'value'=> 'testing' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_contains)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__description", 'operator'=> 'greater_or_equal', 'value'=> 'name' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (is_empty)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'is_empty', 'value'=> '' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include
    end

    it 'return clients with operator (is_not_empty)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'is_not_empty', 'value'=> '' }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (between)' do
      rules = { 'field'=> "tracking__#{program_stream.name}__#{tracking.name}__age", 'operator'=> 'between', 'value'=> ['2', '4'] }
      client_filter = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end
  end
end
