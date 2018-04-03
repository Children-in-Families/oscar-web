describe 'Settings' do
  let(:admin) { create(:user, :admin) }
  # let(:setting) {create(:setting) }

  before do
    login_as(admin)
  end

  feature 'Country', js: true do
    scenario 'default to Cambodia' do
      visit root_path
      expect(current_url).to include('country=cambodia')
    end

    scenario 'switch to Thailand' do
      visit settings_path
      find('.thumbnail#thailand').click

      expect(current_url).to include('country=thailand')
      expect(current_url).not_to include('country=cambodia')
    end
  end

  feature 'Assessment', js: true do
    scenario 'update assessment setting' do
      visit settings_path
      find('.setting_assessment_frequency select option[value="week"]', visible: false).select_option
      fill_in 'setting_min_assessment', with: 4
      fill_in 'setting_max_assessment', with: 7
      click_button 'Create Setting'
      expect(page).to have_content('Weekly')
    end
  end

end
