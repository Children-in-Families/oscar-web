describe ClientAdvancedFilterFields, 'Method' do
  let(:admin) { create(:user, roles: 'admin') }

  before do
    @client_fields = ClientAdvancedFilterFields.new(user: admin).render
  end

  context 'render' do
    it 'return field not nil' do
      expect(@client_fields).not_to be_nil
    end

    it 'return all fields' do
      expect(@client_fields.size).to equal 30
    end
  end
end
