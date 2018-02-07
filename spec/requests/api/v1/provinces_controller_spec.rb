require 'spec_helper'

RSpec.describe Api::V1::ProvincesController, type: :request do
  let(:user) { create(:user) }
  let!(:provinces) { create_list(:province, 25) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/provinces'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/provinces', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the provinces with the correct data' do
        expect(json['provinces'].size).to eq 25
      end
    end
  end
end
