require 'spec_helper'

RSpec.describe Api::V1::DistrictsController, type: :request do
  let(:user) { create(:user) }
  let!(:districts) { create_list(:district, 2) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/districts'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/districts', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the districts with the correct data' do
        expect(json['districts'].size).to eq 2
      end
    end
  end
end
