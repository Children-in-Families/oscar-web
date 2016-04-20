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
      expect(page).to have_link(nil, href: edit_province_path(province))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{province_path(province)}'][data-method='delete']")
    end
  end

  feature 'Create' do
    before do
      visit new_province_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Province has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_province_path(province)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Province has been successfully updated')
    end
    scenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete' do
    before do
      visit provinces_path
    end
    scenario 'success' do
      find("a[href='#{province_path(province, locale: I18n.locale)}'][data-method='delete']").click
      expect(page).to have_content('Province has been successfully deleted')
    end
    scenario 'disable delete' do
      expect(page).not_to have_css("a[href='#{province_path(other_province, locale: I18n.locale)}'][data-method='delete']")
    end
  end
end
