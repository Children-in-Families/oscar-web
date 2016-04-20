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
      expect(page).to have_link('Add New Domain Group', new_domain_group_path(domain_group))
    end
    scenario 'edit link' do
      expect(page).to have_link(nil, edit_domain_group_path(domain_group))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{domain_group_path(domain_group)}'][data-method='delete']")
    end
  end

  feature 'Create' do
    before do
      visit new_domain_group_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Domain Group has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_domain_group_path(domain_group)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Domain Group has been successfully updated')
    end
    scenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete' do
    before do
      visit domain_groups_path
    end
    scenario 'success' do
      find("a[href='#{domain_group_path(domain_group)}'][data-method='delete']").click
      expect(page).to have_content('Domain Group has been successfully deleted')
    end
    scenario 'disable delete' do
      expect(page).not_to have_css("a[href='#{domain_group_path(other_domain_group)}'][data-method='delete']")
    end
  end
end
