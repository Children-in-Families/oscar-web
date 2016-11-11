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
      expect(page).to have_link('Add New Department', new_department_path)
    end
    scenario 'edit link' do
      expect(page).to have_css("i[class='fa fa-pencil']")
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{department_path(department)}'][data-method='delete']")
    end
  end

  feature 'Create', js: true do
    before do
      visit departments_path
    end
    scenario 'valid' do
      click_link('New Department')
      within('#new_department') do
        fill_in 'Name', with: FFaker::Name.name
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Department has been successfully created')
    end
    scenario 'invalid' do
      click_link('New Department')
      within('#new_department') do
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Failed to create a department')
    end
  end

  feature 'Edit', js: true do
    let!(:name){ FFaker::Name.name }
    before do
      visit departments_path
    end
    scenario 'valid' do
      find("a[data-target='#departmentModal-#{department.id}']").click
      within("#departmentModal-#{department.id}") do
        fill_in 'Name', with: name
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Department has been successfully updated')
    end
    scenario 'invalid' do
      find("a[data-target='#departmentModal-#{department.id}']").click
      within("#departmentModal-#{department.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Failed to update a department')
    end
  end

  feature 'Delete', js: true do
    before do
      visit departments_path
    end
    scenario 'success' do
      find("a[href='#{department_path(department)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content('Department has been successfully deleted')
    end
    scenario 'disable' do
      expect(page).to have_css("a[href='#{department_path(other_department)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
