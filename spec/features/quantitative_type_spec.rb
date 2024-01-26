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
    scenario 'list all Custom Referral Data' do
      expect(page).to have_content(quantitative_type.name)
    end
    scenario 'link to edit' do
      expect(page).to have_css("i[class='fa fa-pencil']")
    end
    scenario 'link to delete' do
      expect(page).to have_css("a[href='#{quantitative_type_path(quantitative_type)}'][data-method='delete']")
    end
  end

  feature 'Create', js: true do
    let!(:another_quantitative_type) { create(:quantitative_type, name: 'Another Custom Referral Data') }
    before do
      visit quantitative_types_path
    end
    scenario 'valid' do
      click_link('Add New Custom Referral Data')
      within('#new_quantitative_type') do
        fill_in 'Name', with: 'Test'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Test')
    end
    scenario 'invalid' do
      click_link('Add New Custom Referral Data')
      within('#new_quantitative_type') do
        fill_in 'Name', with: 'Another Custom Referral Data'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Another Custom Referral Data', count: 1)
    end
  end

  feature 'Edit', js: true do
    before do
      visit quantitative_types_path
    end
    scenario 'valid' do
      find("a[data-target='#quantitative_typeModal-#{quantitative_type.id}']").click
      within("#quantitative_typeModal-#{quantitative_type.id}") do
        fill_in 'Name', with: 'Edit Test'
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content('Custom Referral Data has been successfully updated')
    end
    scenario 'invalid' do
      find("a[data-target='#quantitative_typeModal-#{quantitative_type.id}']").click
      within("#quantitative_typeModal-#{quantitative_type.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      sleep 1
      expect(page).to have_content(quantitative_type.name)
    end
  end

  feature 'Delete', js: true do
    before do
      visit quantitative_types_path
    end
    scenario 'success' do
      find("a[href='#{quantitative_type_path(quantitative_type)}'][data-method='delete']").click
      sleep 1
      expect(page).not_to have_content(quantitative_type.name)
    end
    scenario 'disable' do
      expect(page).to have_css("a[href='#{quantitative_type_path(other_quantitative_type)}'][data-method='delete'][class='btn btn-outline btn-danger btn-md disabled']")
    end
  end
end
