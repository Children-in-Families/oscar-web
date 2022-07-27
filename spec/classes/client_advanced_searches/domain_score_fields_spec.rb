describe AdvancedSearches::DomainScoreFields, 'Method' do
  let!(:domain) { create(:domain) }

  before do
    @domain_scores = AdvancedSearches::DomainScoreFields.render.first
  end

  context 'render' do
    it 'return field not nil' do
      expect(@domain_scores).not_to be_nil
    end

    it 'return all fields' do
      expect(@domain_scores.size).to equal 8
    end

    it 'return field with id' do
      expect(@domain_scores[:id]).to eq("all_domains")
    end

    it 'return field with optGroup' do
      expect(@domain_scores[:optgroup]).to eq('CSI Domain Scores')
    end

    it 'return field with label' do
      expect(@domain_scores[:label]).to eq("All Domains")
    end
  end
end
