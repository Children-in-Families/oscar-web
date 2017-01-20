describe 'Domain' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:domain_group){ create(:domain_group) }
  let!(:domain){ create(:domain) }
  let!(:other_domain){ create(:domain) }
  let!(:task){ create(:task, domain: other_domain) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit domains_path
    end
    scenario 'name' do
      expect(page).to have_content(domain.name)
      expect(page).to have_content(other_domain.name)
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Domain', href: new_domain_path)
    end
    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_domain_path(domain))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{domain_path(domain)}'][data-method='delete']")
    end
  end

  feature 'Create', js: true do
    before do
      visit new_domain_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      fill_in 'Identity', with: FFaker::Name.name
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Domain has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_domain_path(domain)
    end
    scenario 'valid', js: true do
      fill_in 'Name', with: name
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Domain has been successfully updated')
    end
    scenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete', js: true do
    before do
      visit domains_path
    end
    scenario 'success' do
      find("a[href='#{domain_path(domain)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content('Domain has been successfully deleted')
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{domain_path(other_domain)}'][data-method='delete'][class='btn btn-outline btn-danger margin-left disabled']")
    end
  end
end
