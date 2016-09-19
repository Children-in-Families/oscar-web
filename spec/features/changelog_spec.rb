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

    scenario 'version' do
      visit "#{changelogs_path}&page=2"
      expect(page).to have_content(changelog.version)
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
      expect(page).to have_link(I18n.t('changelogs.index.add_new_changelog'), new_changelog_path)
    end

    scenario 'pagination' do
      expect(page).to have_css('.pagination')
    end
  end

  feature 'Create' do
    before do
      visit new_changelog_path
    end

    scenario 'valid' do
      fill_in 'Version', with: FFaker::Name.name
      fill_in 'Description', with: FFaker::Lorem.paragraph
      click_button I18n.t('changelogs.form.save')
      expect(page).to have_content(I18n.t('changelogs.create.successfully_created'))
    end

    scenario 'invalid' do
      click_button I18n.t('changelogs.form.save')
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:version) { FFaker::Name.name }
    let!(:other_changelog) { create(:changelog, version: '0.1') }
    before do
      visit edit_changelog_path(changelog)
    end
    scenario 'valid' do
      fill_in 'Version', with: version
      click_button I18n.t('changelogs.form.save')
      expect(page).to have_content(I18n.t('changelogs.update.successfully_updated'))
      expect(page).to have_content(version)
    end
    scenario 'invalid' do
      fill_in 'Version', with: '0.1'
      click_button I18n.t('changelogs.form.save')
      expect(page).to have_content(I18n.t('activerecord.errors.models.changelog.attributes.version.taken'))
    end
  end

  feature 'Delete' do
    before do
      visit changelogs_path
    end
    scenario 'success' do
      find("a[href='#{changelog_path(changelog)}'][data-method='delete']").click
      expect(page).to have_content(I18n.t('changelogs.destroy.successfully_deleted'))
    end
    # scenario 'unsuccess' do
    #   expect(page).not_to have_css("a[href='#{changelog_path(other_changelog)}'][data-method='delete']")
    # end
  end

  feature 'Show' do
    before do
      visit changelog_path(changelog)
    end
    scenario 'success' do
      expect(page).to have_content(changelog.version)
      expect(page).to have_content(changelog.description)
    end
    scenario 'link back to index' do
      expect(page).to have_link(nil, changelogs_path)
    end
  end
end