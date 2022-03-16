describe 'Start Page' do
  # let!(:organization){ create(:organization) }

  feature 'Show', js: true do
    before do
      visit '/'
    end
    scenario 'valid' do
      expect(page).to have_content('Language')
      expect(page).not_to have_content('Forgot your password?')
      expect(page).to have_content('USAID Disclaimer')
      expect(page).to have_css('.organization')
    end
  end
end