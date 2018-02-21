describe Api::V1::DepartmentsController do
  let(:user) { create(:user) }
  let!(:departments) { create_list(:department, 2) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/departments'
      end

      it 'should return unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user logged in' do
      before do
        sign_in(user)
        get '/api/v1/departments', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should return json of departments' do
        expect(json['departments'].size).to eq 2
      end
    end
  end
end
