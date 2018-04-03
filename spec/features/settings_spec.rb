describe 'Settings' do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  feature 'Country', js: true do
    scenario 'default to Cambodia' do
      visit root_path
      expect(current_url).to include('country=cambodia')
    end

    scenario 'switch to Thailand' do
      visit country_settings_path
      find('.thumbnail#thailand').click

      expect(current_url).to include('country=thailand')
      expect(current_url).not_to include('country=cambodia')
    end
  end
end
