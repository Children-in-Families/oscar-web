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

    feature 'validate_organization' do
      feature 'current instance is not Demo' do
        scenario 'stays on the same page' do
          expect(domain_groups_path.split('?').first).to eq(current_path)
        end
      end

      xfeature 'current instance is Demo'
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
    let!(:another_domain_group) { create(:domain_group, name: 'Another Domain Group') }
    before do
      visit domain_groups_path
    end
    scenario 'valid' do
      click_link('New Domain Group')
      within('#new_domain_group') do
        fill_in 'Name', with: 'New Domain Group'
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content('New Domain Group')
    end
    scenario 'invalid' do
      click_link('New Domain Group')
      within('#new_domain_group') do
        fill_in 'Name', with: 'Another Domain Group'
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content('Another Domain Group', count: 1)
    end
  end

  feature 'Edit', js: true do
    before do
      visit domain_groups_path
    end
    scenario 'valid' do
      find("a[data-target='#domain_groupModal-#{domain_group.id}']").click
      within("#domain_groupModal-#{domain_group.id}") do
        fill_in 'Name', with: 'Update Domain Name'
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content('Update Domain Name')
    end
    scenario 'invalid' do
      find("a[data-target='#domain_groupModal-#{domain_group.id}']").click
      within("#domain_groupModal-#{domain_group.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content(domain_group.name)
    end
  end

  feature 'Delete', js: true do
    before do
      visit domain_groups_path
    end
    scenario 'success' do
      find("a[href='#{domain_group_path(domain_group)}'][data-method='delete']").click
      expect(page).not_to have_content(domain_group.name)
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{domain_group_path(other_domain_group)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
