describe 'Family' do
  let!(:admin){ create(:user, :admin) }
  let!(:province){ create(:province, name:"Phnom Penh") }
  let!(:district){ create(:district, name: 'Toul Kork', province_id: province.id) }
  let!(:client){ create(:client, :accepted) }

  before do
    Rails.cache.clear
    login_as(admin)
  end

  feature 'Create', js: true do
    before do
      visit new_family_path
    end
    scenario 'valid' do
      fill_in 'Head Household Name (Latin)', with: 'Family Name'
      find(".family_family_type select option[value='Birth Family (Both Parents)']", visible: false).select_option
      find("#family_family_type", visible: false).set('Short Term/Emergency Foster Care')
      click_link 'Next'
      fill_in 'family[family_members_attributes][0][adult_name]', with: 'Test'
      find(".family_family_members_gender select option[value='female']", visible: false).select_option
      click_link 'Save'
      wait_for_ajax
      expect(page).to have_content('Family Name')
      expect(page).to have_content('Test')
    end

    scenario 'invalid' do
      click_link 'Next'
      expect(page).to have_content("This field is required.")
    end
  end
end
