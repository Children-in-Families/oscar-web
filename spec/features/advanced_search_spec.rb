describe 'AdvancedSearch' do
  let(:user_1) { create(:user) }
  let(:user_2) { create(:user) }

  feature 'List' do
    let!(:advanced_search_1){ create(:advanced_search, user: user_1, created_at: Date.yesterday) }
    let!(:advanced_search_6){ create(:advanced_search, user: user_2, created_at: Date.today) }

    before do
      login_as(user_1)
      visit clients_path
    end

    scenario 'Save Search Settting' do
      expect(page).to have_button('Save Search Settings')
    end

    scenario 'Load Search Settting' do
      expect(page).to have_button('Load Saved Search')
    end

    feature 'Search Settings List', js: true do
      scenario 'my saved search' do
        page.find('#load-saved-search').click
        expect(page).to have_content(advanced_search_1.name)
        expect(page).to have_content(advanced_search_1.description)
        expect(page).to have_content(advanced_search_1.created_at.strftime('%d %B, %Y'))
        expect(page).to have_link(nil, edit_advanced_search_save_query_path(advanced_search_1))
        expect(page).to have_css("a[href='#{advanced_search_save_query_path(advanced_search_1)}'][data-method='delete']")

        expect(page).not_to have_content(advanced_search_6.name)
        expect(page).not_to have_content(advanced_search_6.description)
        expect(page).not_to have_content(advanced_search_6.owner)
        expect(page).not_to have_content(advanced_search_6.created_at.strftime('%d %B, %Y'))
      end

      scenario 'saved search of other people within org' do
        page.find('#load-saved-search').click
        page.find('#other-saved-searches-tab').click
        expect(page).to have_content(advanced_search_6.name)
        expect(page).to have_content(advanced_search_6.description)
        expect(page).to have_content(advanced_search_6.owner)
        expect(page).to have_content(advanced_search_6.created_at.strftime('%d %B, %Y'))
        expect(page).not_to have_css("a[href='#{edit_advanced_search_save_query_path(advanced_search_6)}']")
        expect(page).not_to have_css("a[href='#{advanced_search_save_query_path(advanced_search_6)}'][data-method='delete']")
      end
    end
  end

  feature 'create', js: true do
    let!(:advanced_search_2){ create(:advanced_search, user: user_1, name: 'User1 Client') }
    before do
      login_as(user_1)
      visit clients_path
    end

    # pending as the button is not enabled
    xscenario 'valid', js: true do
      page.find('#save-search-setting').click
      fill_in 'Name', with: 'OSCaR client'
      click_button('#submit-query')
      page.find('#load-saved-search').click
      expect(page).to have_content('OSCaR client')
    end

    # pending as the button is not enabled
    xscenario 'invalid as taken' do
      page.find('#save-search-setting').click
      fill_in 'Name', with: 'User1 client'
      click_button('#submit-query')
      expect(page).to have_content("Search setting has already been taken.")
    end
  end

  feature 'edit', js: true do
    let!(:advanced_search_3){ create(:advanced_search, user: user_1) }
    let!(:advanced_search_4){ create(:advanced_search, name: 'Able client', user: user_1) }
    before do
      login_as(user_1)
      visit edit_advanced_search_save_query_path(advanced_search_3)
    end

    scenario 'valid' do
      fill_in 'Name', with: 'Accepted client'
      click_button 'Save'
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

  feature 'delete' do
    let!(:advanced_search_5){ create(:advanced_search, user: user_1) }
    before do
      login_as(user_1)
      visit clients_path
    end

    scenario 'succcess' do
      page.find('#load-saved-search').click
      find("a[href='#{advanced_search_save_query_path(advanced_search_5)}'][data-method='delete']").click
      sleep 1
      page.find('#load-saved-search').click
      expect(page).not_to have_content(advanced_search_5.name)
    end
  end
end
