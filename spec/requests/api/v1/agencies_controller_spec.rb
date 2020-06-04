require 'spec_helper'

describe Api::V1::AgenciesController, type: :request do
  let(:user) { create(:user) }
  let!(:agencies) { create_list(:agency, 5) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/agencies'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/agencies', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the agencies with the correct data' do
        expect(json['agencies'].size).to eq 5
      end
    end
  end
end
