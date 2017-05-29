require 'spec_helper'

RSpec.describe Api::V1::CustomFieldPropertiesController, type: :request do
  let(:user) { create(:user) }
  let!(:client) { create(:client, user: user) }
  let!(:custom_field) { create(:custom_field) }
  let!(:custom_field_property) { create(:custom_field_property, custom_field_id: custom_field.id, custom_formable_id: client.id) }
  let!(:second_custom_field_property) { create(:custom_field_property, custom_field_id: custom_field.id, custom_formable_id: client.id) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get "/api/v1/clients/#{client.id}/custom_field_properties?custom_field_id=#{custom_field.id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get "/api/v1/clients/#{client.id}/custom_field_properties?custom_field_id=#{custom_field.id}", @auth_headers
      end

      it 'should return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should returns the custom field properties with the correct data' do
        expect(json['custom_field_properties'].size).to eq 2
        expect(json['custom_field_properties'].map { |cfp| cfp['properties'] }).to include(custom_field_property.properties)
        expect(json['custom_field']['id']).to eq(custom_field.id)
      end
    end
  end

  describe 'GET #show' do
    context 'when user not loged in' do
      before do
        get "/api/v1/clients/#{client.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get "/api/v1/clients/#{client.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}", @auth_headers
      end

      it 'should return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should returns the custom field properties with the correct data' do
        expect(json['custom_field_properties']['properties']).to eq(custom_field_property.properties)
        expect(json['custom_field']['id']).to eq(custom_field.id)
      end
    end
  end

  describe 'GET #new' do
    context 'when user not loged in' do
      before do
        get "/api/v1/clients/#{client.id}/custom_field_properties/new?custom_field_id=#{custom_field.id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        get "/api/v1/clients/#{client.id}/custom_field_properties/new?custom_field_id=#{custom_field.id}", @auth_headers
      end

      it 'should return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should returns custom field structure' do
        expect(json['custom_field']['properties']).to eq(custom_field.properties)
      end
    end
  end

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/clients/#{client.id}/custom_field_properties?custom_field_id=#{custom_field.id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to create custom field properties' do
        before do
          custom_field_property_params = { format: 'json', custom_field_property: { properties: {"Text Field": "Testing" } } }
          post "/api/v1/clients/#{client.id}/custom_field_properties?custom_field_id=#{custom_field.id}", custom_field_property_params, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return correct data' do
          expect(json['properties']).to eq({"Text Field" => "Testing"})
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'when user not loged in' do
      before do
        put "/api/v1/clients/#{client.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to update custom field properties' do
        before do
          custom_field_property_params = { format: 'json', custom_field_property: { properties: {"Text Field": "Updating" } } }
          put "/api/v1/clients/#{client.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}", custom_field_property_params, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return correct data' do
          expect(json['properties']).to eq({"Text Field" => "Updating"})
        end
      end
    end
  end

  describe 'DELETE #delete' do
    context 'when user not loged in' do
      before do
        delete "/api/v1/clients/#{client.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to delete custom field properties' do
        before do
          delete "/api/v1/clients/#{client.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}", @auth_headers
        end

        it 'should return status 204' do
          expect(response).to have_http_status(:no_content)
        end

        it 'should not have contain custom field properties' do
          expect(CustomFieldProperty.all.map { |cfp| cfp.id }).not_to include(custom_field_property.id)
        end
      end

      context 'when try to delete attachment' do
        before do
          delete "/api/v1/clients/#{client.id}/custom_field_properties/#{second_custom_field_property.id}?custom_field_id=#{custom_field.id}&file_index=0", @auth_headers
        end

        it 'should return status 204' do
          expect(response).to have_http_status(:no_content)
        end

        it 'should delete only attachment' do
          expect(second_custom_field_property.persisted?).to be_truthy
          expect(second_custom_field_property.attachments.blank?).to be_truthy
        end
      end
    end
  end
end
