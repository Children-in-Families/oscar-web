describe 'Agency' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:agency){ create(:agency) }
  let!(:other_agency){ create(:agency) }
  let!(:client){ create(:client, agencies: [other_agency]) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit agencies_path
    end
    scenario 'name' do
      expect(page).to have_content(agency.name)
      expect(page).to have_content(other_agency.name)
    end
    scenario 'new link' do
      expect(page).to have_link('Add New Agency', new_agency_path)
    end
    scenario 'edit link' do
      expect(page).to have_css("i[class='fa fa-pencil']")
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{agency_path(agency)}'][data-method='delete']")
    end
  end

  feature 'Create' do
    before do
      visit agencies_path
    end
    scenario 'valid', js: true do
      click_link 'Add New Agency'
      within("#new_agency") do
        fill_in 'Name', with: FFaker::Name.name
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Agency has been successfully created')
    end

    scenario 'invalid', js: true do
      click_link 'Add New Agency'
      within('#new_agency') do
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content("Failed to create an agency")
    end
  end

  feature 'Edit', js: true do
    let!(:name){ FFaker::Name.name }
    before do
      visit agencies_path
    end
    scenario 'valid' do
      find("a[data-target='#agencyModal-#{agency.id}']").click
      within("#agencyModal-#{agency.id}") do
        fill_in 'Name', with: name
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Agency has been successfully updated')
      expect(page).to have_content(name)
    end
    scenario 'invalid' do
      find("a[data-target='#agencyModal-#{agency.id}']").click
      within("#agencyModal-#{agency.id}") do
        fill_in I18n.t('agencies.form.name'), with: ''
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Failed to update an agency')
    end
  end

  feature 'Delete', js: true do
    before do
      visit agencies_path
    end
    scenario 'success' do
      find("a[href='#{agency_path(agency)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content('Agency has been successfully deleted')
    end
    scenario 'disable link' do
      sleep 1
      expect(page).to have_css("a[href='#{agency_path(other_agency)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
