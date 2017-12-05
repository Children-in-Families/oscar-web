describe AdvancedSearches::ClientFields, 'Method' do
  let(:admin) { create(:user, roles: 'admin') }

  before do
    @client_fields = AdvancedSearches::ClientFields.new(user: admin).render
  end

  context 'render' do
    it 'return field not nil' do
      expect(@client_fields).not_to be_nil
    end
  end
end
