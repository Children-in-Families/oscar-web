require 'spec_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:user) { create(:user) }

  describe 'PUT/PATCH #update' do
    context 'when user not loged in' do
      before do
        put "/api/v1/users/#{user.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to update pin number' do
        before do
          user_param = { format: 'json', user: { pin_number: 1111 } }
          put "/api/v1/users/#{user.id}", user_param, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return new pin number' do
          expect(json['pin_number']).to eq 1111
        end
      end
    end
  end
end
