xdescribe AdvancedSearches::RuleFields, 'Method' do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  let(:admin) { create(:user, roles: 'admin') }

  before do
    @client_fields = AdvancedSearches::RuleFields.new(user: admin).render
  end

  context 'render' do
    it 'return field not nil' do
      expect(@client_fields).not_to be_nil
    end
  end
end
