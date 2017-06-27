require 'spec_helper'

RSpec.describe Api::V1::DonorsController, type: :request do
  let(:user) { create(:user) }
  let!(:donors) { create_list(:donor, 10) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/donors'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/donors', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the donors with the correct data' do
        expect(json['donors'].size).to eq 10
      end
    end
  end
end
