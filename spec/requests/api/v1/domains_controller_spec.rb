require 'spec_helper'

RSpec.describe Api::V1::DomainsController, type: :request do
  let(:user) { create(:user) }
  let!(:domains) { create_list(:domain, 12) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/domains'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/domains', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the domains with the correct data' do
        expect(json['domains'].size).to eq 12
      end
    end
  end
end
