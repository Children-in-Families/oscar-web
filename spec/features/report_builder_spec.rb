describe 'Report Builder' do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, :accepted, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Juliet', local_family_name: 'Romeo', date_of_birth: 10.years.ago, users: [user]) }

  before do
    Rails.cache.clear
    login_as(user)
    Rails.cache.clear
  end

  feature 'Search client', js: true do
    scenario 'for client' do
      visit clients_path
      find('.client-search').click
      expect(page).to have_content('Search')
      find('#client-grid-search-btn').click
      sleep 10
      expect(page).to have_content("Adam")
    end
  end

  feature 'Search family', js: true do
    let!(:family){ create(:family, children: [client.id] ) }
    scenario 'for family' do
      visit families_path
      fill_in 'Family ID', with: family.id
      find('#client-grid-search-btn').click
      sleep 10
      expect(page).to have_content(family.id)
    end
  end
end
