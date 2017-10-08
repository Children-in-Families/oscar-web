describe 'AdvancedSearch' do
  let(:user_1) { create(:user) }

  feature 'List', js: true do
    let!(:advanced_search_1){ create(:advanced_search) }

    before do
      login_as(user_1)
      visit client_advanced_searches_path
    end

    scenario 'Save Search Settting' do
      expect(page).to have_button('Save Search Settings')
    end

    scenario 'Load Search Settting' do
      expect(page).to have_button('Load Saved Search')
    end

    scenario 'Search Settings List' do
      page.find('#load-saved-search').click
      expect(page).to have_content(advanced_search_1.name)
      expect(page).to have_content(advanced_search_1.description)
      expect(page).to have_link(nil, edit_advanced_search_save_query_path(advanced_search_1))
      expect(page).to have_css("a[href='#{advanced_search_save_query_path(advanced_search_1)}'][data-method='delete']")
    end
  end

  xfeature 'create', js: true do
    let!(:advanced_search_2){ create(:advanced_search) }
    before do
      login_as(user_1)
      visit client_advanced_searches_path
    end

    scenario 'valid' do
      page.find('#save-search-setting').click
      fill_in 'Name', with: 'OSCaR client'
      click_button 'Save'
      expect(page).to have_content('Search setting has been successfully created.')
      page.find('#load-saved-search').click
      expect(page).to have_content('OSCaR client')
    end

    scenario 'invalid as taken' do
      page.find('#save-search-setting').click
      fill_in 'Name', with: 'OSCaR client'
      click_button 'Save'
      expect(page).to have_content("Search setting has already been taken.")
    end
  end

  feature 'edit', js: true do
    let!(:advanced_search_3){ create(:advanced_search) }
    let!(:advanced_search_4){ create(:advanced_search, name: 'Able client') }
    before do
      login_as(user_1)
      visit edit_advanced_search_save_query_path(advanced_search_3)
    end

    scenario 'valid' do
      fill_in 'Name', with: 'Accepted client'
      click_button 'Save'
      expect(page).to have_content('Search setting has been successfully updated.')
      page.find('#load-saved-search').click
      expect(page).to have_content('Accepted client')
    end

    scenario 'invalid as blank' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end

    scenario 'invalid as taken' do
      fill_in 'Name', with: 'Able client'
      click_button 'Save'
      expect(page).to have_content("has already been taken")
    end
  end

  feature 'delete', js: true do
    let!(:advanced_search_5){ create(:advanced_search) }
    before do
      login_as(user_1)
      visit client_advanced_searches_path
    end

    scenario 'succcess' do
      page.find('#load-saved-search').click
      find("a[href='#{advanced_search_save_query_path(advanced_search_5)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content('Search setting has been successfully deleted.')
    end
  end
end
