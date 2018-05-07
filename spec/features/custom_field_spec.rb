feature 'custom_field' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:custom_field) { create(:custom_field, frequency: 'Daily', time_of_frequency: 1) }
  let!(:search_custom_field) { create(:custom_field, form_title: 'Search Custom Field', frequency: 'Daily', time_of_frequency: 1) }

  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      Organization.switch_to 'demo'
      CustomField.create(form_title: 'Other NGO Custom Field', fields: [{'type'=>'text', 'label'=>'Hello World'}].to_json, entity_type: 'Client')
      Organization.switch_to 'app'
      visit custom_fields_path
    end

    scenario 'form title' do
      expect(page).to have_content(custom_field.form_title)
    end

    scenario 'type' do
      expect(page).to have_content(custom_field.entity_type)
    end

    scenario 'frequency' do
      expect(page).to have_content('This needs to be done once every day.')
    end

    scenario 'organization' do
      expect(page).to have_content(custom_field.ngo_name)
    end

    scenario 'new link' do
      expect(page).to have_link('New Custom Form', href: new_custom_field_path)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_custom_field_path(custom_field))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{custom_field_path(custom_field)}'][data-method='delete']")
    end

    scenario 'show link' do
      expect(page).to have_link(nil, href: preview_custom_fields_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name))
    end

    scenario 'list my ngo custom fields', js: true do
      find('a[href="#custom-form"]').click
      expect(page).to have_content(custom_field.form_title)
    end

    scenario 'list all ngo custom fields', js: true do
      find('a[href="#all-custom-form"]').click
      expect(page).to have_content(custom_field.form_title)
    end

    scenario 'list demo ngo custom fields', js: true do
      find('a[href="#demo-custom-form"]').click
      expect(page).to have_content('Other NGO Custom Field')
      expect(page).to have_content('Demo')
    end
  end

  feature 'preview' do
    before do
      visit preview_custom_fields_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name)
    end

    scenario 'form title' do
      expect(page).to have_content(custom_field.form_title)
    end

    scenario 'fields', js: true do
      expect(page).to have_content('Name')
    end

    scenario 'edit link' do
      expect(page).to have_link('Edit', href: edit_custom_field_path(custom_field))
    end

    scenario 'back link' do
      expect(page).to have_link('Back', href: custom_fields_path)
    end
  end

  feature 'create', js: true do
    before do
      visit new_custom_field_path
    end

    xscenario 'valid' do
      find("select option[value='Client']", visible: false).select_option
      fill_in 'Form Title', with: 'Testing'
      find("select option[value='Daily']", visible: false).select_option
      find('li[data-type="date"]').click
      find("input[type=submit]").click
      expect(page).to have_content('Testing')
    end

    scenario 'invalid' do
      fill_in 'Form Title', with: FFaker::Name.name
      find("select option[value='Daily']", visible: false).select_option
      find("input[type=submit]").click
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'edit', js: true do
    before do
      visit edit_custom_field_path(custom_field)
    end

    xscenario 'valid' do
      fill_in 'Form Title', with: 'Update Form'
      find("input[type=submit]").click
      expect(page).to have_content('Update Form')
    end

    scenario 'invalid' do
      fill_in 'Form Title', with: ''
      find("input[type=submit]").click
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'destroy', js: true do
    before do
      visit custom_fields_path
    end

    scenario 'successfully deleted' do
      find("a[href='#{custom_field_path(custom_field)}'][data-method='delete']").click
      expect(page).to have_content('Custom Form has been successfully deleted.')
    end
  end

  feature 'copy', js: true do
    before do
      visit custom_fields_path
    end

    xscenario 'valid' do
      click_link "All NGOs' Custom Forms"
      click_link(nil, href: new_custom_field_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name))
      fill_in 'Form Title', with: 'Copy'
      find("input[type=submit]").click
      expect(page).to have_content('Copy')
    end

    scenario 'invalid' do
      click_link "All NGOs' Custom Forms"
      click_link(nil, href: new_custom_field_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name))
      find("input[type=submit]").click
      expect(page).to have_content('has already been taken')
    end
  end

  feature 'search', js: true do
    before do
      Organization.switch_to 'demo'
      CustomField.create(form_title: 'Other Custom Field', fields: [{'type'=>'text', 'label'=>'Hello World'}].to_json, entity_type: 'Client')
      Organization.switch_to 'app'
      visit custom_fields_path
    end

    scenario 'search custom field in current organization' do
      fill_in 'Form Title', with: 'Search Custom Field'
      find('input[type=submit]').click
      expect(page).to have_content('Search Custom Field')
    end

    scenario 'search custom field in other organization' do
      fill_in 'Form Title', with: 'Other Custom Field'
      find('input[type=submit]').click
      expect(page).to have_content('Other Custom Field')
    end

    scenario 'search custom field in all organization' do
      fill_in 'Form Title', with: 'Custom Field'
      find('input[type=submit]').click
      expect(page).to have_content('Search Custom Field')
      expect(page).to have_content('Other Custom Field')
    end
  end
end
