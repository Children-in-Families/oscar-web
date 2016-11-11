describe 'Material' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:material){ create(:material, status: 'AAA') }
  let!(:used_material){ create(:material) }
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note){ create(:progress_note, material: used_material, location: location) }

  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      FactoryGirl.create_list(:material, 20)
      visit materials_path
    end

    scenario 'status' do
      expect(page).to have_content(material.status)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_material_path(material))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{material_path(material)}'][data-method='delete']")
    end

    scenario 'new link' do
      expect(page).to have_link(I18n.t('materials.index.add_new_material'), new_material_path)
    end

    scenario 'pagination' do
      expect(page).to have_css('.pagination')
    end
  end

  feature 'Create', js: true do
    before do
      visit materials_path
    end

    scenario 'valid' do
      click_link('Add New Equipment/Material')
      within('#new_material') do
        fill_in I18n.t('materials.form.status'), with: FFaker::Lorem.word
        click_button I18n.t('materials.form.save')
      end
      sleep 1
      expect(page).to have_content(I18n.t('materials.create.successfully_created'))
    end

    scenario 'invalid' do
      click_link('Add New Equipment/Material')
      within('#new_material') do
        click_button I18n.t('materials.form.save')
      end
      sleep 1
      expect(page).to have_content('Failed to create an Equipment/Material')
    end
  end

  feature 'Edit', js: true do
    let!(:status) { FFaker::Name.name }
    let!(:other_material) { create(:material, status: 'Loan') }
    before do
      visit materials_path
    end
    scenario 'valid' do
      find("a[data-target='#materialModal-#{other_material.id}']").click
      within("#materialModal-#{other_material.id}") do
        fill_in I18n.t('materials.form.status'), with: status
        click_button I18n.t('materials.form.save')
      end
      sleep 1
      expect(page).to have_content(I18n.t('materials.update.successfully_updated'))
      expect(page).to have_content(status)
    end
    scenario 'invalid' do
      find("a[data-target='#materialModal-#{other_material.id}']").click
      within("#materialModal-#{other_material.id}") do
        fill_in I18n.t('materials.form.status'), with: ''
        click_button I18n.t('materials.form.save')
      end
      sleep 1
      expect(page).to have_content('Failed to update an Equipment/Material')
    end
  end

  feature 'Delete', js: true do
    before do
      visit materials_path
    end
    scenario 'success' do
      find("a[href='#{material_path(material)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content(I18n.t('materials.destroy.successfully_deleted'))
    end

    scenario 'does not succeed' do
      expect(page).to have_css("a[href='#{material_path(used_material)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
