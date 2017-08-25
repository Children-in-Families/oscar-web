describe 'task' do
  let!(:admin) { create(:user, roles: 'admin') }
  let!(:client) { create(:client) }
  let!(:task) { create(:task, client: client, user_ids: admin.id) }

  feature 'list' do
    before do
      login_as(admin)
      visit tasks_path
    end

    scenario 'client link', js: true do
      page.find(".form-group select option[value='#{admin.id}']", visible: false).select_option
      expect(page).to have_link(client.name, href: client_path(client))
    end
  end
end
