describe 'Changelog' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:changelog){ create(:changelog) }

  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      FactoryGirl.create_list(:changelog, 20)
      visit changelogs_path
    end

    scenario 'change_version' do
      visit "#{changelogs_path}&page=2"
      expect(page).to have_content(changelog.change_version)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_changelog_path(changelog))
    end

    scenario 'delete link' do
      visit "#{changelogs_path}&page=2"
      expect(page).to have_css("a[href='#{changelog_path(changelog)}'][data-method='delete']")
    end

    scenario 'show link' do
      expect(page).to have_link(nil, changelog_path(changelog))
    end

    scenario 'new link' do
      expect(page).to have_link(I18n.t('changelogs.index.add_new_release'), new_changelog_path)
    end
  end

  feature 'Create', js: true do
    before do
      visit changelogs_path
    end

    scenario 'valid' do
      click_link('Add New Release')
      sleep 2
      within('#new_changelog') do
        fill_in 'changelog_change_version', with: 'Stable Version'
        click_link('Add change')
        find(:css, "input.description").set('This is valid')
        click_button 'Save'
      end
      expect(page).to have_content('Stable Version')
      expect(page).to have_content('This is valid')
    end

    scenario 'invalid' do
      click_link('Add New Release')
      within('#new_changelog') do
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content(changelog.change_version)
      expect(page).to have_content(date_format(changelog.created_at))
    end
  end

  feature 'Edit', js: true do
    let!(:change_version) { FFaker::Name.name }
    let!(:other_changelog) { create(:changelog, change_version: '0.1') }

    before do
      visit changelogs_path(changelog)
    end
    scenario 'valid' do
      find("a[data-target='#changelogModal-#{changelog.id}']").click
      within("#changelogModal-#{changelog.id}") do
        fill_in 'changelog_change_version', with: change_version
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content(change_version)
    end
    scenario 'invalid' do
      find("a[data-target='#changelogModal-#{changelog.id}']").click
      within("#changelogModal-#{changelog.id}") do
        fill_in 'changelog_change_version', with: '0.1'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content(changelog.change_version)
      expect(page).to have_content(date_format(changelog.created_at))
    end
  end

  feature 'Delete', js: true do
    before do
      visit changelogs_path
    end
    scenario 'success' do
      find("a[href='#{changelog_path(changelog)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content(I18n.t('changelogs.destroy.successfully_deleted'))
    end
  end

  feature 'Show' do
    before do
      visit changelog_path(changelog)
    end
    scenario 'success' do
      expect(page).to have_content(changelog.change_version)
    end
    scenario 'link back to index' do
      expect(page).to have_link(nil, changelogs_path)
    end
  end
end
