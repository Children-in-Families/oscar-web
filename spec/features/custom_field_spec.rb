feature 'custom_field' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:custom_field) { create(:custom_field, frequency: 'Daily', time_of_frequency: 1) }

  before do 
    login_as(admin)
  end

  feature 'List' do
    before do
      visit custom_fields_path
    end

    scenario 'form title' do
      expect(page).to have_content(custom_field.form_title)
    end

    scenario 'type' do
      expect(page).to have_content(custom_field.entity_type)
    end

    scenario 'frequency' do
      expect(page).to have_content('This need to be done once every day.')
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
  end

  feature 'preview' do
    before do
      visit preview_custom_fields_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name)
    end

    scenario 'form title' do
      expect(page).to have_content(custom_field.form_title)
    end

    scenario 'fields', js: true do
      expect(page).to have_content('Hello World')
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

    scenario 'valid' do
      fill_in 'Form Title', with: FFaker::Name.name
      find("select option[value='Daily']", visible: false).select_option
      find('.icon-text-input').click
      find("input[type=submit]").click
      expect(page).to have_content('Custom Form has been successfully created.') 
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

    scenario 'valid' do
      fill_in 'Form Title', with: FFaker::Name.name
      find("input[type=submit]").click
      expect(page).to have_content('Custom Form has been successfully updated.') 
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

    scenario 'valid' do
      click_link "All NGOs' Custom Forms"
      click_link(nil, href: new_custom_field_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name))
      fill_in 'Form Title', with: FFaker::Name.name
      find("input[type=submit]").click
      expect(page).to have_content('Custom Form has been successfully created.')
    end

    scenario 'invalid' do
      click_link "All NGOs' Custom Forms"
      click_link(nil, href: new_custom_field_path(custom_field_id: custom_field.id, ngo_name: custom_field.ngo_name))
      find("input[type=submit]").click
      expect(page).to have_content('has already been taken')
    end
  end
end