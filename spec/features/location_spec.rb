describe 'Location' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other', order_option: 1) }
  let!(:used_location){ create(:location) }
  let!(:new_location){ create(:location) }
  let!(:progress_note){ create(:progress_note, location: used_location) }

  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      FactoryGirl.create_list(:location, 20)
      visit locations_path
    end

    scenario 'name' do
      visit '/locations?page=2'
      expect(page).to have_content(location.name)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_location_path(location))
    end

    scenario 'diable delete link' do
      expect(page).not_to have_css("a[href='#{location_path(location)}'][data-method='delete']")
    end

    scenario 'new link' do
      expect(page).to have_link(I18n.t('locations.index.add_new_location'), new_location_path)
    end

    scenario 'pagination' do
      expect(page).to have_css('.pagination')
    end
  end

  feature 'Create', js: true do
    before do
      visit locations_path
    end

    scenario 'valid' do
      click_link('Add New Location')
      within('#new_location') do
        fill_in I18n.t('locations.form.name'), with: FFaker::Company.name
        click_button I18n.t('locations.form.save')
      end
      sleep 1
      expect(page).to have_content(I18n.t('locations.create.successfully_created'))
    end

    scenario 'invalid' do
      click_link('Add New Location')
      within('#new_location') do
        click_button I18n.t('locations.form.save')
      end
      sleep 1
      expect(page).to have_content('Failed to create a location.')
    end
  end

  feature 'Edit', js: true do
    let!(:name) { FFaker::Company.name }
    let!(:other_location) { create(:location, name: 'Home') }
    before do
      visit locations_path
    end
    scenario 'valid' do
      find("a[data-target='#locationModal-#{other_location.id}']").click
      within("#locationModal-#{other_location.id}") do
        fill_in I18n.t('locations.form.name'), with: name
        click_button I18n.t('locations.form.save')
      end
      sleep 1
      expect(page).to have_content(I18n.t('locations.update.successfully_updated'))
      expect(page).to have_content(name)
    end
    scenario 'invalid' do
      find("a[data-target='#locationModal-#{other_location.id}']").click
      within("#locationModal-#{other_location.id}") do
        fill_in I18n.t('locations.form.name'), with: ''
        click_button I18n.t('locations.form.save')
      end
      sleep 1
      expect(page).to have_content('Failed to update a location.')
    end
  end

  feature 'Delete', js: true do
    before do
      visit locations_path
    end
    scenario 'success' do
      find("a[href='#{location_path(new_location)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content(I18n.t('locations.destroy.successfully_deleted'))
    end

    scenario 'does not succeed' do
      expect(page).to have_css("a[href='#{location_path(used_location)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
