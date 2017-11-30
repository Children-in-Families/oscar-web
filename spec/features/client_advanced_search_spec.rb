describe 'ClientAdvancedSearch' do
  let!(:admin) { create(:user, roles: 'admin') }

  feature 'List client basic field', js: true do

    background do
      login_as(admin)
      visit clients_path
    end

    scenario 'Advanced search link' do
      expect(page).to have_content 'Report Builder'
    end

    xscenario 'Advanced Search Text Field' do
      click_link 'Advanced Search'
      find(".rule-filter-container select option[value='given_name']", visible: false).select_option
      expect(page).to have_content 'Given Name'
      expect(page).to have_content 'is'
    end

    xscenario 'Advanced Search Number Field' do
      click_link 'Advanced Search'
      find(".rule-filter-container select option[value='code']", visible: false).select_option
      expect(page).to have_content 'Code'
      expect(page).to have_content 'is'
    end

    xscenario 'Advanced Search Drop list Field' do
      click_link 'Advanced Search'
      find(".rule-filter-container select option[value='gender']", visible: false).select_option
      expect(page).to have_content 'Female'
      expect(page).to have_content 'is'
      value = find(".rule-value-container select option[value='Accepted']", visible: false)
      expect(value).to have_text 'Accepted'
    end

    xscenario 'Advanced Search Datepicker Field' do
      click_link 'Advanced Search'
      find(".rule-filter-container select option[value='placement_date']", visible: false).select_option
      expect(page).to have_content 'Placement Start Date'
      expect(page).to have_content 'is'
    end
  end
end
