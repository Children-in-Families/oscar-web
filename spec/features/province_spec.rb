describe 'Province' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:province){ create(:province) }
  let!(:other_province){ create(:province) }
  let!(:case){ create(:case, province: other_province) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit provinces_path
    end
    scenario 'name' do
      expect(page).to have_content(province.name)
    end
    scenario 'edit link' do
      expect(page).to have_css("i[class='fa fa-pencil']")
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{province_path(province)}'][data-method='delete']")
    end
  end

  feature 'Create', js: true do
    before do
      visit provinces_path
    end
    scenario 'valid' do
      click_link('Add New Province')
      within('#new_province') do
        fill_in 'Name', with: FFaker::Name.name
        click_button 'Save'
      end
      expect(page).to have_content('Province has been successfully created')
    end
    scenario 'invalid' do
      click_link('Add New Province')
      within('#new_province') do
        click_button 'Save'
      end
      expect(page).to have_content('Failed to create a province.')
    end
  end

  feature 'Edit', js: true do
    let!(:name){ FFaker::Name.name }
    before do
      visit provinces_path
    end
    scenario 'valid' do
      find("a[data-target='#provinceModal-#{province.id}']").click
      within("#provinceModal-#{province.id}") do
        fill_in 'Name', with: name
        click_button 'Save'
      end
      expect(page).to have_content('Province has been successfully updated')
    end
    scenario 'invalid' do
      find("a[data-target='#provinceModal-#{province.id}']").click
      within("#provinceModal-#{province.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      expect(page).to have_content('Failed to update a province.')
    end
  end

  feature 'Delete', js: true do
    before do
      visit provinces_path
    end
    scenario 'success' do
      find("a[href='#{province_path(province, locale: I18n.locale)}'][data-method='delete']").click
      expect(page).to have_content('Province has been successfully deleted')
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{province_path(other_province, locale: I18n.locale)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
