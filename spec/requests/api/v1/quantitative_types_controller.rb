require 'spec_helper'

RSpec.describe Api::V1::QuantitativeTypesController, type: :request do
  let(:user) { create(:user) }
  let!(:quantitative_types) { create_list(:quantitative_type, 12) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/quantitative_types'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/quantitative_types', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the quantitative_types with the correct data' do
        expect(json['quantitative_types'].size).to eq 12
      end
    end
  end
end
