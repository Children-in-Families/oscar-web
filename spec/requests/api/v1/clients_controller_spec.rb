require 'spec_helper'

RSpec.describe Api::V1::ClientsController, type: :request do
  let(:user) { create(:user) }
  let!(:clients) { create_list(:client, 5, user: user) }

  # describe 'GET #index' do
  #   context 'when user not loged in' do
  #     before do
  #       get '/api/v1/clients'
  #     end
  #
  #     it 'should be return status 401' do
  #       expect(response).to have_http_status(:unauthorized)
  #     end
  #   end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/clients', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the clients with the correct data' do
        expect(json['clients'].size).to eq 5
        expect(json['clients'].map { |client| client['user']['email'] }).to include(user.email)
      end
    end
  end
end
