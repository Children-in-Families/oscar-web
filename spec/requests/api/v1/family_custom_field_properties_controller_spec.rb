require 'spec_helper'

RSpec.describe Api::V1::CustomFieldPropertiesController, type: :request do
  let(:user) { create(:user) }
  let!(:family) { create(:family) }
  let!(:custom_field) { create(:custom_field, entity_type: 'Family') }
  let!(:custom_field_property) { create(:custom_field_property, :family_custom_field_property, custom_field_id: custom_field.id, custom_formable_id: family.id) }
  let!(:second_custom_field_property) { create(:custom_field_property, :family_custom_field_property, custom_field_id: custom_field.id, custom_formable_id: family.id) }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/families/#{family.id}/custom_field_properties?custom_field_id=#{custom_field.id}"
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
          post "/api/v1/families/#{family.id}/custom_field_properties?custom_field_id=#{custom_field.id}", custom_field_property_params, @auth_headers
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
        put "/api/v1/families/#{family.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}"
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
          put "/api/v1/families/#{family.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}", custom_field_property_params, @auth_headers
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
        delete "/api/v1/families/#{family.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}"
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
          delete "/api/v1/families/#{family.id}/custom_field_properties/#{custom_field_property.id}?custom_field_id=#{custom_field.id}", @auth_headers
        end

        it 'should return status 204' do
          expect(response).to have_http_status(:no_content)
        end

        it 'should not have contain custom field properties' do
          expect(CustomFieldProperty.ids).not_to include(custom_field_property.id)
        end
      end

      context 'when try to delete attachment' do
        before do
          delete "/api/v1/families/#{family.id}/custom_field_properties/#{second_custom_field_property.id}?custom_field_id=#{custom_field.id}&file_index=0", @auth_headers
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
