describe AdvancedSearches::ClientAssociationFilter, 'Method' do
  let!(:user)           { create(:user) }
  let!(:agency)         { create(:agency) }
  let!(:family)         { create(:family) }
  let!(:custom_field)   { create(:custom_field) }
  let!(:program_stream) { create(:program_stream) }

  let!(:client)         { create(:client, date_of_birth: 10.years.ago) }
  let!(:ec_client)      { create(:client) }
  let!(:fc_client)      { create(:client) }
  let!(:kc_client)      { create(:client) }

  let!(:exit_ec_client) { create(:client) }
  let!(:exit_fc_client) { create(:client) }
  let!(:exit_kc_client) { create(:client) }

  let!(:ec_case)   { create(:case, :emergency, start_date: 1.day.ago, client: ec_client, family: family) }
  let!(:fc_case)   { create(:case, :foster, start_date: 2.days.ago, client: fc_client, family: family) }
  let!(:kc_case)   { create(:case, :kinship, start_date: 3.days.ago, client: kc_client, family: family) }

  let!(:exit_ec_case)   { create(:case, :emergency, :inactive, start_date: 4.days.ago, client: exit_ec_client, family: family) }
  let!(:exit_fc_case)   { create(:case, :foster, :inactive, start_date: 5.days.ago, client: exit_fc_client, family: family) }
  let!(:exit_kc_case)   { create(:case, :kinship, :inactive, start_date: 6.days.ago, client: exit_kc_client, family: family) }

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

    it 'return clients that filter with family_id' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'family_id', 'equal', family.id).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include ec_client.id, fc_client.id, kc_client.id, exit_ec_client.id, exit_fc_client.id, exit_kc_client.id
    end

    it 'return clients that filter with family' do
      client_filter = AdvancedSearches::ClientAssociationFilter.new(Client.all, 'family', 'equal', family.name).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include ec_client.id, fc_client.id, kc_client.id, exit_ec_client.id, exit_fc_client.id, exit_kc_client.id
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
