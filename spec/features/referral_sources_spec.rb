describe 'Referral Sources' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:referral_source){ create(:referral_source) }
  let!(:other_referral_source){ create(:referral_source) }
  let!(:referral_source_1){ create(:referral_source, name: 'អង្គការមិនមែនរដ្ឋាភិបាល') }
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
  feature 'Create', js: true do
    let!(:another_referral_source) { create(:referral_source, name: 'Another Referral Source') }
    before do
      visit referral_sources_path
    end
    scenario 'valid' do
      click_link('Add New Referral Source')
      within('#new_referral_source') do
        fill_in 'Name', with: 'Test'
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content('Test')
    end
    scenario 'invalid' do
      click_link('Add New Referral Source')
      within('#new_referral_source') do
        fill_in 'Name', with: 'Another Referral Source'
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content('Another Referral Source', count: 1)
    end
  end
  feature 'Edit', js: true do
    before do
      visit referral_sources_path
    end
    scenario 'valid' do
      find("a[data-target='#referral_sourceModal-#{referral_source.id}']").click
      within("#referral_sourceModal-#{referral_source.id}") do
        fill_in 'Name', with: 'testing'
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content('testing')
    end
    scenario 'invalid' do
      find("a[data-target='#referral_sourceModal-#{referral_source.id}']").click
      within("#referral_sourceModal-#{referral_source.id}") do
        fill_in 'Name', with: ''
        click_button 'Save'
      end
      wait_for_ajax
      expect(page).to have_content(referral_source.name)
    end

    scenario 'cannot be updated' do
      expect(page).to have_css("a[class='btn btn-outline btn-success btn-xs disabled'][data-target='#referral_sourceModal-#{referral_source_1.id}']")
    end
  end
  feature 'Delete' do
    before do
      visit referral_sources_path
    end
    scenario 'success', js: true do
      find("a[href='#{referral_source_path(referral_source)}'][data-method='delete']").click
      wait_for_ajax
      expect(page).not_to have_content(referral_source.name)
    end
    scenario 'disable delete' do
      expect(page).to have_css("a[href='#{referral_source_path(referral_source_1)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
