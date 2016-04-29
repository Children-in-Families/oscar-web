describe 'Quantitative Type' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:quantitative_type){ create(:quantitative_type) }
  let!(:other_quantitative_type){ create(:quantitative_type) }
  let!(:quantitative_case){ create(:quantitative_case, quantitative_type: other_quantitative_type) }
  before do
    login_as(admin)
  end
  feature 'Index' do
    before do
      visit quantitative_types_path
    end
    scenario 'list all Quantitative Type' do
      expect(page).to have_content(quantitative_type.name)
    end
    scenario 'link to edit' do
      expect(page).to have_link(nil, href: edit_quantitative_type_path(quantitative_type))
    end
    scenario 'link to delete' do
      expect(page).to have_css("a[href='#{quantitative_type_path(quantitative_type)}'][data-method='delete']")
    end
  end

  feature 'Create' do
    before do
      visit new_quantitative_type_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Quantitative Type has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_quantitative_type_path(quantitative_type)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Quantitative Type has been successfully updated')
    end
    scenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete' do
    before do
      visit quantitative_types_path
    end
    scenario 'success' do
      find("a[href='#{quantitative_type_path(quantitative_type)}'][data-method='delete']").click
      expect(page).to have_content('Quantitative Type has been successfully deleted')
    end
    scenario 'disable' do
      expect(page).not_to have_css("a[href='#{quantitative_type_path(other_quantitative_type)}'][data-method='delete']")
    end
  end
end
