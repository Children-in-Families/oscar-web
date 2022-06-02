describe 'Report Builder' do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, :accepted, users: [user]) }
  let!(:family){ create(:family, children: [client.id] ) }
  before do
    login_as(user)
  end

  feature 'Search', js: true do
    scenario 'for client' do
      visit clients_path
      find('.client-search').click
      find('#client-grid-search-btn').click
      sleep 1
      expect(page).to have_content(client.given_name)
    end
    scenario 'for family' do
      visit families_path
      find('#client-grid-search-btn').click
      sleep 1
      expect(page).to have_content(family.name)
    end
  end
end