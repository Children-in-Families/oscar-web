feature 'ClientAdvancedSearch', js: true do
  given(:admin) { create(:user, roles: 'admin') }

  background do
    login_as(admin)
    visit clients_path
  end

  scenario 'Advanced search link' do
    expect(page).to have_content 'Advanced Search'
  end

  scenario 'Advanced Search Text Field' do
    click_link 'Advanced Search'
    find(".rule-filter-container select option[value='given_name']", visible: false).select_option
    expect(page).to have_content 'Given Name'
    expect(page).to have_content 'is'
  end

  scenario 'Advanced Search Number Field' do
    click_link 'Advanced Search'
    find(".rule-filter-container select option[value='code']", visible: false).select_option
    expect(page).to have_content 'Code'
    expect(page).to have_content 'is'
  end
  xscenario 'Advanced Search Drop list Field' do
    click_link 'Advanced Search'
    find(".rule-filter-container select option[value='able_state']", visible: false).select_option
    expect(page).to have_content 'Able State'
    expect(page).to have_content 'is'
    expect(page).to have_content 'Accepted'
  end

  scenario 'Advanced Search Datepicker Field' do
    click_link 'Advanced Search'
    find(".rule-filter-container select option[value='placement_date']", visible: false).select_option
    expect(page).to have_content 'Placement Start Date'
    expect(page).to have_content 'is'
  end
end
