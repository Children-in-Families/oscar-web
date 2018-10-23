describe 'VisitClient' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client_1){ create(:client, given_name: 'Rainy') }

  before do
    login_as(admin)
  end

  feature 'Client show page' do
    feature 'from clients list/index' do
      before(:each) do
        visit clients_path
        find('.client-search').click
        sleep 1
        first('.datagrid-actions').click_button 'Search'
      end
      scenario 'increase visit client by 1' do
        first("a[href='#{client_path(client_1)}']").click
        sleep 1
        expect(admin.visit_clients.count).to eq(1)
      end
    end

    feature 'from url/bookmark' do
      before do
        visit client_path(client_1)
      end
      scenario 'does not increase visit client by 1' do
        expect(admin.visit_clients.count).to eq(0)
      end
    end
  end
end
