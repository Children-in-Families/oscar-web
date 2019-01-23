describe AdvancedSearches::QuantitativeCaseSqlBuilder, 'Method' do
  let!(:quantitative_type)          { create(:quantitative_type) }

  let!(:client)                     { create(:client) }
  let!(:quantitative_case)          { create(:quantitative_case, quantitative_type: quantitative_type) }
  let!(:client_quantitative_case)   { create(:client_quantitative_case, client: client, quantitative_case: quantitative_case) }

  let!(:client2)                     { create(:client) }
  let!(:quantitative_case2)         { create(:quantitative_case, quantitative_type: quantitative_type) }
  let!(:client_quantitative_case2)   { create(:client_quantitative_case, client: client2, quantitative_case: quantitative_case2) }

  let!(:client3)                     { create(:client) }

  context '#get_sql' do
    it 'return clients with operator (equal)' do
      rules = { 'field'=> "quantitative__#{quantitative_type.id}", 'operator'=> 'equal', 'value'=> quantitative_case.id }
      client_filter = AdvancedSearches::QuantitativeCaseSqlBuilder.new(Client.all, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end

    it 'return clients with operator (not_equal)' do
      rules = { 'field'=> "quantitative__#{quantitative_type.id}", 'operator'=> 'not_equal', 'value'=> quantitative_case.id }
      client_filter = AdvancedSearches::QuantitativeCaseSqlBuilder.new(Client.all, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client2.id
    end

    it 'return clients with operator (is_empty)' do
      rules = { 'field'=> "quantitative__#{quantitative_type.id}", 'operator'=> 'is_empty', 'value'=> '' }
      client_filter = AdvancedSearches::QuantitativeCaseSqlBuilder.new(Client.all, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client3.id
    end

    it 'return clients with operator (is_not_empty)' do
      rules = { 'field'=> "quantitative__#{quantitative_type.id}", 'operator'=> 'is_not_empty', 'value'=> '' }
      client_filter = AdvancedSearches::QuantitativeCaseSqlBuilder.new(Client.all, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include client.id
    end
  end
end
