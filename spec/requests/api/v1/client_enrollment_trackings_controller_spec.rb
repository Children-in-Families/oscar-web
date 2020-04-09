require 'spec_helper'

describe Api::V1::ClientEnrollmentTrackingsController, type: :request do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end

  let(:user)                            { create(:user) }
  let(:client)                          { create(:client, users: [user]) }
  let(:program_stream)                  { create(:program_stream) }
  let(:client_enrollment)               { create(:client_enrollment, client: client, program_stream: program_stream) }
  let(:tracking)                        { create(:tracking, program_stream: program_stream) }
  let(:client_enrollment_tracking)      { create(:client_enrollment_tracking, client_enrollment: client_enrollment, tracking: tracking) }
  let(:valid_params)                    { params(FFaker::Internet.email, "2", FFaker::Lorem.paragraph) }
  let(:invalid_params)                  { params(FFaker::Name.name, "7", nil) }
  let(:valid_updated_params)            { params(FFaker::Internet.email, "2", FFaker::Lorem.paragraph) }
  let(:invalid_updated_params)          { params(FFaker::Name.name, "7", nil) }
  let(:client_enrollment_trackings_path){ "/api/v1/clients/#{client.id}/client_enrollments/#{client_enrollment.id}/client_enrollment_trackings" }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "#{client_enrollment_trackings_path}?tracking_id=#{tracking.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when user loged in' do
      before do
        sign_in(user)
      end

      xcontext 'when try create client enrollment tracking with valid value' do
        before do
          post "#{client_enrollment_trackings_path}?tracking_id=#{tracking.id}", valid_params, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should be return client enrollment with correct data' do
          expect(json['properties']).to eq properties(valid_params)
        end
      end

      context 'when try create client enrollment tracking with invalid value' do
        before do
          post "#{client_enrollment_trackings_path}?tracking_id=#{tracking.id}", invalid_params, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return error message' do
          expect(json.values.flatten).to include "can't be blank"
          expect(json.values.flatten).to include "can't be greater than 5"
          expect(json.values.flatten).to include "is not an email"
        end
      end

    end
  end

  describe 'PUT #update' do
    context 'when user not loged in' do
      before do
        put "#{client_enrollment_trackings_path}/#{client_enrollment_tracking.id}?tracking_id=#{tracking.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try update client enrollment tracking' do
        before do
          put "#{client_enrollment_trackings_path}/#{client_enrollment_tracking.id}?tracking_id=#{tracking.id}", valid_updated_params, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should be return client enrollment tracking with correct data' do
          expect(json['properties']).to eq properties(valid_updated_params)
        end
      end

      context 'when try update client enrollment tracking with invalid value' do
        before do
          put "#{client_enrollment_trackings_path}/#{client_enrollment_tracking.id}?tracking_id=#{tracking.id}", invalid_updated_params, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return error message' do
          expect(json.values.flatten).to include "can't be blank"
          expect(json.values.flatten).to include "can't be greater than 5"
          expect(json.values.flatten).to include "is not an email"
        end
      end

    end
  end

  def properties(params)
    params[:client_enrollment_tracking][:properties]
  end

  def params(email, age, description)
    { format: 'json', client_enrollment_tracking: { properties: { "e-mail" => email, "age" => age, "description" => description } } }
  end
end
