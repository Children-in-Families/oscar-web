require 'spec_helper'

describe Api::V1::ClientsController, type: :request do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end

  let(:user) { create(:user, :admin) }
  let!(:clients) { create_list(:client, 5, users: [user]) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/clients'
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    context 'when user not loged in' do
      before do
        get "/api/v1/clients/#{clients[0].id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    xcontext 'when user loged in' do
      before do
        sign_in(user)
        get "/api/v1/clients/#{clients[0].id}", @auth_headers
      end

      it 'should return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should returns the client with the correct data' do
        expect(json['client']['id']).to eq(clients[0].id)
      end
    end
  end

  describe 'POST #create' do
    let!(:referral_source){ create(:referral_source) }
    context 'when user not loged in' do
      before do
        post "/api/v1/clients"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to create client' do
        let!(:global_identity) { create(:global_identity) }
        before do
          client = {  format: 'json',
                      client: { 
                        given_name: 'example',
                        family_name: 'family_name',
                        local_given_name: 'local_given_name', 
                        local_family_name: 'local_family_name',
                        gender: 'male', 
                        reason_for_referral: 'test',
                        date_of_birth: '2018-02-19',
                        referral_source_category_id: referral_source.id,
                        initial_referral_date: '2022-02-02',
                        user_ids: [user.id],
                        received_by_id: user.id,
                        global_id: global_identity.ulid
                      }
                    }
          post "/api/v1/clients", client, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return correct data' do
          expect(json['client']['given_name']).to eq("example")
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'when user not loged in' do
      before do
        put "/api/v1/clients/#{clients[0].id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    xcontext 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to update client' do
        let!(:given_name) { FFaker::Name.name }
        before do
          client = { format: 'json', client: { given_name: given_name } }
          put "/api/v1/clients/#{clients[0].id}", client, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return updated data' do
          expect(json['client']['given_name']).to eq(given_name)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user not loged in' do
      before do
        delete "/api/v1/clients/#{clients[0].id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to delete client' do
        before do
          delete "/api/v1/clients/#{clients[0].id}", @auth_headers
        end

        it 'should return status 204' do
          expect(response).to have_http_status(:no_content)
        end

        it 'should not contain deleted client' do
          expect(Client.ids).not_to include(clients[0].id)
        end
      end
    end
  end
end
