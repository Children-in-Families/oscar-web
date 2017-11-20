describe 'VisitClient' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client_1){ create(:client, given_name: 'Rainy') }
  let!(:client_2){ create(:client) }
  let!(:client_3){ create(:client) }
  before do
    login_as(admin)
  end
  feature 'Client show page' do
    feature 'from clients list/index' do
      before(:each) do
        visit clients_path
      end
      scenario 'increase visit client by 1' do
        first("a[href='#{client_path(client_1)}']").click
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
