describe 'Settings' do
  let!(:admin) { create(:user, :admin) }
  let!(:setting) { Setting.first }

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

  feature 'Cambodian NGO information', js: true do
    let(:case_worker) { create(:user, :case_worker) }

    scenario 'only admin can edit' do
      visit edit_setting_path(setting)
      fill_in 'setting_org_name', with: 'Demo'
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Setting have been successfully updated.')
    end

    scenario 'cannot edit if none-admin' do
      login_as(case_worker)
      visit edit_setting_path(setting)
      expect(page).to have_content('You are not authorized to access this page.')
    end

    scenario 'cannot edit if non-cambodian NGO' do
      setting.update(country_name: 'thailand')
      visit root_path
      find('.profile-element').click
      expect(page).to_not have_content('Edit Organization Profile')
    end
  end

end
