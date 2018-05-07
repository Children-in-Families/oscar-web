describe AdvancedSearches::ClientAssociationFilter, 'Method' do
  let!(:user)           { create(:user) }
  let!(:agency)         { create(:agency) }
  let!(:custom_field)   { create(:custom_field) }
  let!(:program_stream) { create(:program_stream) }

  let!(:client)                { create(:client, date_of_birth: 10.years.ago) }
  let!(:agency_client)         { create(:agency_client, client: client, agency: agency) }
  let!(:case_worker_client)    { create(:case_worker_client, user: user, client: client) }

  let!(:client_enrollment)     { create(:client_enrollment, client: client, program_stream: program_stream) }
  let!(:custom_field_property) { create(:custom_field_property, custom_field: custom_field, custom_formable_id: client.id) }

  context '#get_sql' do
    it 'return clients that filter with form_title' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'form_title', 'equal', custom_field.id).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients that filter with user_id' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'user_id', 'equal', user.id).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients that filter with agency_name' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'agency_name', 'equal', agency.id).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients that filter with age' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'age', 'not_equal', 11).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients that filter with program_stream' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'program_stream', 'equal', program_stream.id).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end
  end
end
