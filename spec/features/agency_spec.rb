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
      expect(page).to have_link(nil, href: edit_agency_path(agency))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{agency_path(agency)}'][data-method='delete']")
    end
  end

  feature 'Create' do
    before do
      visit new_agency_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Agency has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_agency_path(agency)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Agency has been successfully updated')
      expect(page).to have_content(name)
    end
    scenario 'invalid' do
      fill_in I18n.t('agencies.form.name'), with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete' do
    before do
      visit agencies_path
    end
    scenario 'success' do
      find("a[href='#{agency_path(agency)}'][data-method='delete']").click
      expect(page).to have_content('Agency has been successfully deleted')
    end
    scenario 'disable link' do
      expect(page).not_to have_css("a[href='#{agency_path(other_agency)}'][data-method='delete']")
    end
  end
end
