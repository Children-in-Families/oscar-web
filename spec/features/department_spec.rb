describe 'Department' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:department){ create(:department) }
  let!(:other_department){ create(:department) }
  let!(:user){ create(:user, department: other_department) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit departments_path
    end
    scenario 'name' do
      expect(page).to have_content(department.name)
      expect(page).to have_content(other_department.name)
    end
    scenario 'new link ' do
      expect(page).to have_link('Add New Department', href: new_department_path)
    end
    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_department_path(department))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{department_path(department)}'][data-method='delete']")
    end
  end

  feature 'Create' do
    before do
      visit new_department_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Department has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_department_path(department)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Department has been successfully updated')
    end
    scenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete' do
    before do
      visit departments_path
    end
    scenario 'success' do
      find("a[href='#{department_path(department)}'][data-method='delete']").click
      expect(page).to have_content('Department has been successfully deleted')
    end
    scenario 'disable' do
      expect(page).not_to have_css("a[href='#{department_path(other_department)}'][data-method='delete']")
    end
  end
end
