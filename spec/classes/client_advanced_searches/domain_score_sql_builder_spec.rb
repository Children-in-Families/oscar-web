describe AdvancedSearches::DomainScoreSqlBuilder, 'Method' do
  let!(:client)                     { create(:client) }
  let!(:assessment)                 { create(:assessment, client: client) }
  let!(:assessment_domain)          { create(:assessment_domain, assessment: assessment, domain: domain, score: 4) }
  let!(:domain)                     { create(:domain) }
  let!(:client2)                    { create(:client) }
  let!(:assessment2)                { create(:assessment, client: client2) }
  let!(:assessment_domain1)         { create(:assessment_domain, assessment: assessment2, domain: domain, score: 3) }
  let!(:client3)                    { create(:client) }

  context '#get_sql' do
    it 'return clients with operator (equal)' do
      rules = { 'field'=> "domainscore_#{domain.id}_#{domain.identity} (#{domain.name})", 'operator'=> 'equal', 'value'=> '4' }
      client_filter = AdvancedSearches::DomainScoreSqlBuilder.new(domain.id, rules).get_sql

      expect(client_filter[:id]).to include('clients.id IN (?)')
      expect(client_filter[:values]).to include(client.id)
    end

    it 'return clients with operator (not_equal)' do
      rules = { 'field'=> "domainscore_#{domain.id}_#{domain.identity} (#{domain.name})", 'operator'=> 'not_equal', 'value'=> '4' }
      client_filter = AdvancedSearches::DomainScoreSqlBuilder.new(domain.id, rules).get_sql

      expect(client_filter[:id]).to include('clients.id IN (?)')
      expect(client_filter[:values]).to include(client2.id)
      expect(client_filter[:values]).not_to include(client.id)
    end

    it 'return clients with operator (between)' do
      rules = { 'field'=> "domainscore_#{domain.id}_#{domain.identity} (#{domain.name})", 'operator'=> 'between', 'value'=> ['3', '4'] }
      client_filter = AdvancedSearches::DomainScoreSqlBuilder.new(domain.id, rules).get_sql

      expect(client_filter[:id]).to include 'clients.id IN (?)'
      expect(client_filter[:values]).to include(client.id, client2.id)
      expect(client_filter[:values]).not_to include(client3.id)
    end
  end
end
