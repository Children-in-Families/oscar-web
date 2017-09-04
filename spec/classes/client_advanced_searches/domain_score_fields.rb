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
      expect(@domain_scores.size).to equal 6
    end

    it 'return field with id' do
      expect(@domain_scores[:id]).to include("domainscore_#{domain.id}_#{domain.identity} (#{domain.name})")
    end

    it 'return field with optGroup' do
      expect(@domain_scores[:optgroup]).to include('CSI Domain Scores')
    end

    it 'return field with label' do
      expect(@domain_scores[:label]).to include("#{domain.identity} (#{domain.name})")
    end
  end
end
