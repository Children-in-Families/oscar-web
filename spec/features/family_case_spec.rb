describe 'Case' do
  let!(:admin)  { create(:user, roles: 'admin') }
  let!(:family) { create(:family, family_type: "emergency", name:"EC Family", address: "Phnom Penh") }
  let!(:client) { create(:client, state: 'accepted') }

  feature 'Create' do
    before do
      login_as admin
      visit new_family_case_path(family)
    end

    scenario 'valid', js: true do
      within '#new_case' do
        fill_in 'Start Date', with: '2017-07-01'
        find("select#case_case_type option[value='EC']", visible: false).select_option
        find("select#case_client_id option[value='#{client.id}']", visible: false).select_option
      end
      click_button 'Save'
      expect(page).to have_content('Successfully added client to family')
    end

    scenario 'invalid' do
      within '#new_case' do
        find("select#case_case_type option[value='EC']", visible: false).select_option
      end
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end
end