require 'spec_helper'

RSpec.describe Api::V1::LeaveProgramsController, type: :request do

  let(:user)                   { create(:user) }
  let(:client)                 { create(:client, users: [user]) }
  let(:program_stream)         { create(:program_stream) }
  let(:client_enrollment)      { create(:client_enrollment, client: client, program_stream: program_stream, enrollment_date: '2017-06-08') }
  let(:leave_program)          { create(:leave_program, client_enrollment: client_enrollment, program_stream: program_stream) }
  let(:valid_params)           { params(FFaker::Internet.email, "2", FFaker::Lorem.paragraph, '2017-06-09') }
  let(:invalid_params)         { params(FFaker::Name.name, "7", nil, nil) }
  let(:valid_updated_params)   { params(FFaker::Internet.email, "2", FFaker::Lorem.paragraph, '2017-06-09') }
  let(:invalid_updated_params) { params(FFaker::Name.name, "7", nil, nil) }
  let(:leave_programs_path)    { "/api/v1/clients/#{client.id}/client_enrollments/#{client_enrollment.id}/leave_programs" }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "#{leave_programs_path}?program_stream_id=#{program_stream.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try create leave_program with valid value' do
        before do
          post "#{leave_programs_path}?program_stream_id=#{program_stream.id}", valid_params, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should be return leave_program with correct data' do
          expect(json['properties']).to eq properties(valid_params)
        end
      end

      context 'when try create leave_program with invalid value' do
        before do
          post "#{leave_programs_path}?program_stream_id=#{program_stream.id}", invalid_params, @auth_headers
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
        put "#{leave_programs_path}/#{leave_program.id}?program_stream_id=#{program_stream.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try update leave_program' do
        before do
          put "#{leave_programs_path}/#{leave_program.id}?program_stream_id=#{program_stream.id}", valid_updated_params, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should be return leave_program with correct data' do
          expect(json['properties']).to eq properties(valid_updated_params)
        end
      end

      context 'when try update leave_program with invalid value' do
        before do
          put "#{leave_programs_path}/#{leave_program.id}?program_stream_id=#{program_stream.id}", invalid_updated_params, @auth_headers
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
    params[:leave_program][:properties]
  end

  def params(email, age, description, exit_date)
    { format: 'json', leave_program: { exit_date: exit_date, properties: { "e-mail" => email, "age" => age, "description" => description } } }
  end
end
