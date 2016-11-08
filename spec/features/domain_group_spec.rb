describe 'Domain Group' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:domain_group){ create(:domain_group) }
  let!(:other_domain_group){ create(:domain_group) }
  let!(:domain){ create(:domain, domain_group: other_domain_group) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit domain_groups_path
    end
    scenario 'name' do
      expect(page).to have_content(domain_group.name)
    end
    scenario 'new link' do
      expect(page).to have_link('Add New Domain Group', nil)
    end
    scenario 'edit link' do
      expect(page).to have_css("i[class='fa fa-pencil']")
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{domain_group_path(domain_group)}'][data-method='delete']")
    end
  end

  feature 'Create', js: true do
    before do
      visit domain_groups_path
    end
    sleep 1
    scenario 'valid' do
      click_link('New Domain Group')
      within('#new_domain_group') do
        fill_in 'Name', with: FFaker::Name.name
        click_button 'Save'
      end
      expect(page).to have_content('Domain Group has been successfully created')
    end
    scenario 'invalid' do
      sleep 1
      click_link('New Domain Group')
      within('#new_domain_group') do
        click_button 'Save'
      end
      expect(page).to have_content('Failed to create a domain group.')
    end
  end

  feature 'Edit', js: true do
    let!(:name){ FFaker::Name.name }
    before do
      visit domain_groups_path
    end
    scenario 'valid' do
      find("a[data-target='#domain_groupModal-#{domain_group.id}']").click
      within("#domain_groupModal-#{domain_group.id}") do
        fill_in 'Name', with: name
        click_button 'Save'
      end
      expect(page).to have_content('Domain Group has been successfully updated')
    end
    scenario 'invalid' do
      sleep 1
      find("a[data-target='#domain_groupModal-#{domain_group.id}']").click
      within("#domain_groupModal-#{domain_group.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      expect(page).to have_content('Failed to update a domain group.')
    end
  end

  feature 'Delete', js: true do
    before do
      visit domain_groups_path
    end
    scenario 'success' do
      find("a[href='#{domain_group_path(domain_group)}'][data-method='delete']").click
      expect(page).to have_content('Domain Group has been successfully deleted')
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{domain_group_path(other_domain_group)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
