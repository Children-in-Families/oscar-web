RSpec.describe Api::V1::UsersController, type: :request do
  let(:user) { create(:user, roles: "admin") }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/users'
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/users', @auth_headers
      end

      context 'when user try to get self and subordinates' do
        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when user not loged in' do
      before do
        get '/api/v1/users'
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get "/api/v1/users/#{user.id}", @auth_headers
      end

      context 'when user try to get self and subordinates' do
        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
