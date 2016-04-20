describe 'Referral Sources' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:referral_source){ create(:referral_source) }
  let!(:other_referral_source){ create(:referral_source) }
  let!(:client){ create(:client, referral_source: other_referral_source) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit referral_sources_path
    end
    scenario 'name' do
      expect(page).to have_content(referral_source.name)
    end
    scenario 'new link' do
      expect(page).to have_link('Add New Referral Source', edit_referral_source_path(referral_source))
    end
    scenario 'edit link' do
      expect(page).to have_link(nil, edit_referral_source_path(referral_source))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{referral_source_path(referral_source)}'][data-method='delete']")
    end
  end
  feature 'Create' do
    before do
      visit new_referral_source_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Referral Source has been successfully created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end
  feature 'Edit' do
    let!(:name){ FFaker::Name.name }
    before do
      visit edit_referral_source_path(referral_source)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Referral Source has been successfully updated')
    end
    scenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end
  feature 'Delete' do
    before do
      visit referral_sources_path
    end
    scenario 'success' do
      find("a[href='#{referral_source_path(referral_source)}'][data-method='delete']").click
      expect(page).to have_content('Referral Source has been successfully deleted')
    end
    scenario 'disable delete' do
      expect(page).not_to have_css("a[href='#{referral_source_path(other_referral_source)}'][data-method='delete']")
    end
  end
end
