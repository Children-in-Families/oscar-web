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
    let!(:another_domain) { create(:domain, name: 'Another Domain') }
    before do
      visit new_domain_path
    end
    scenario 'valid' do
      fill_in 'Name', with: 'Domain Name'
      fill_in 'Identity', with: 'Domain Identity'
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Domain Name')
      expect(page).to have_content('Domain Identity')
    end
    scenario 'invalid' do
      fill_in 'Name', with: 'Another Domain'
      fill_in 'Identity', with: 'Domain Identity'
      click_button 'Save'
      expect(page).to have_content('Please review the problems below')
    end
  end

  feature 'Edit' do
    before do
      visit edit_domain_path(domain)
    end
    scenario 'valid', js: true do
      fill_in 'Name', with: 'Updated Domain Name'
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Updated Domain Name')
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
      expect(page).not_to have_content(domain.name)
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{domain_path(other_domain)}'][data-method='delete'][class='btn btn-outline btn-danger margin-left disabled']")
    end
  end
end
