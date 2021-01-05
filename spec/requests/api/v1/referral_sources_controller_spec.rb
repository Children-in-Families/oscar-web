require 'spec_helper'

RSpec.describe Api::V1::ReferralSourcesController, type: :request do
  let(:user) { create(:user) }
  let!(:referral_sources) { create_list(:referral_source, 5) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/referral_sources'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/referral_sources', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      xit 'should be returns the referral sources with the correct data' do
        expect(json['referral_sources'].size).to eq 5
      end
    end
  end
end
