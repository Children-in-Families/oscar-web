describe 'Settings' do
  let(:admin) { create(:user, :admin) }
  # let(:setting) {create(:setting) }

  before do
    login_as(admin)
  end

  feature 'Assessment', js: true do
    scenario 'update assessment setting' do
      visit settings_path
      find('.setting_assessment_frequency select option[value="month"]', visible: false).select_option
      # fill_in 'setting_min_assessment', with: 4
      fill_in 'setting_max_assessment', with: 7
      click_button 'Save'
      expect(page).to have_css('.setting_assessment_frequency select option[selected="selected"]', text: 'Month', visible: false)
    end
  end

  feature 'Case Note', js: true do
    scenario 'update case note setting' do
      visit settings_path
      find('.setting_case_note_frequency select option[value="week"]', visible: false).select_option
      fill_in 'setting_max_case_note', with: 4
      click_button 'Save'
      expect(page).to have_css('.setting_case_note_frequency select option[selected="selected"]', text: 'Week', visible: false)
    end
  end
end
