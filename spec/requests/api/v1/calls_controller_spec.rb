require 'spec_helper'

xdescribe Api::V1::CallsController, type: :request do
  let(:user) { create(:user) }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/calls"
      end

      it 'should return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      let!(:phone_call_id) { FFaker::Time.date }
      before do
        sign_in(user)
      end

      context 'valid when try to create call' do
        before do
          call_params = {
            format: 'json',
            call: {
                      phone_call_id: phone_call_id, receiving_staff_id: user.id,
                      start_datetime: DateTime.new, end_datetime: DateTime.new,
                      call_type: Call::CALL_TYPE.sample
                    }
          }

          post "/api/v1/calls", call_params, @auth_headers
        end

        it 'should return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should return correct data' do
          expect(json['call']['phone_call_id']).to eq(phone_call_id)
        end
      end

      context 'invalid when try to create call without mandatory fields' do
        before do
          call_params = {
            format: 'json',
            call: { phone_call_id: phone_call_id }
          }

          post "/api/v1/calls", call_params, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return validation message' do
          expect(json['receiving_staff_id']).to eq ['can\'t be blank']
          expect(json['start_datetime']).to eq ['can\'t be blank']
          expect(json['end_datetime']).to eq ['can\'t be blank']
          expect(json['call_type']).to eq ['can\'t be blank', 'is not included in the list']
        end
      end
    end
  end
end
