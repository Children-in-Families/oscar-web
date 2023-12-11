describe 'Organization Type' do
  let!(:admin){ create(:user, :admin) }
  let!(:organization_type){ create(:organization_type, name: 'ABC') }
  let!(:other_organization_type){ create(:organization_type) }
  let!(:partner){ create(:partner, organization_type_id: other_organization_type.id) }

  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit organization_types_path
    end
    scenario 'name' do
      expect(page).to have_content(organization_type.name)
    end
    scenario 'edit link' do
      expect(page).to have_css("i[class='fa fa-pencil']")
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{organization_type_path(organization_type)}'][data-method='delete']")
    end
  end

  feature 'Create', js: true do
    let!(:other_organization_type) { create(:organization_type, name: 'NGO') }
    before do
      visit organization_types_path
    end
    scenario 'valid' do
      click_link('Add New Organisation Type')
      within('#new_organization_type') do
        fill_in 'Name', with: 'Church'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Church')
    end
    scenario 'invalid' do
      click_link('Add New Organisation Type')
      within('#new_organization_type') do
        fill_in 'Name', with: 'NGO'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('NGO', count: 1)
    end
  end

  feature 'Edit', js: true do
    before do
      visit organization_types_path
    end
    scenario 'valid' do
      find("a[data-target='#organization_typeModal-#{organization_type.id}']").click
      within("#organization_typeModal-#{organization_type.id}") do
        fill_in 'Name', with: 'Government'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Government')
    end
    scenario 'invalid' do
      find("a[data-target='#organization_typeModal-#{organization_type.id}']").click
      within("#organization_typeModal-#{organization_type.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('ABC')
    end
  end

  feature 'Delete', js: true do
    before do
      visit organization_types_path
    end
    scenario 'success' do
      find("a[href='#{organization_type_path(organization_type)}'][data-method='delete']").click
      sleep 1
      expect(page).not_to have_content('ABC')
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{organization_type_path(other_organization_type)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end