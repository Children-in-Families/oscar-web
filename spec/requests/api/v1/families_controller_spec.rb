require 'spec_helper'

RSpec.describe Api::V1::FamiliesController, type: :request do
  let(:user) { create(:user) }
  let!(:families) { create_list(:family, 2) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/families'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get '/api/v1/families', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the families with the correct data' do
        expect(json['families'].size).to eq 2
      end
    end
  end

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/families"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to create family' do
        let!(:name) { FFaker::Name.name }
        before do
          family_params = { format: 'json', family: { name: name, code: "fam-001", status: 'Active', family_type: 'Other' } }
          post "/api/v1/families", family_params, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return correct data' do
          expect(json['family']['name']).to eq(name)
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'when user not loged in' do
      before do
        put "/api/v1/families/#{families[0].id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to update family' do
        let!(:name) { FFaker::Name.name }
        before do
          family_params = { format: 'json', family: { name: name } }
          put "/api/v1/families/#{families[0].id}", family_params, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return updated data' do
          expect(json['family']['name']).to eq(name)
        end
      end
    end
  end
end
