require 'spec_helper'

RSpec.describe Api::V1::ProgramStreamsController, type: :request do
  let(:user) { create(:user) }
  let!(:program_stream) { create(:program_stream) }
  let!(:tracking)       { create(:tracking, program_stream: program_stream, name: FFaker::Name.name) }
  let!(:other_tracking) { create(:tracking, program_stream: program_stream, name: FFaker::Name.name) }

  describe 'GET #index' do
    context 'when user not loged in' do
      before do
        get '/api/v1/program_streams'
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        program_stream.update(name: FFaker::Name.name)
        get '/api/v1/program_streams', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the program_stream with the correct data' do
        expect(json['program_streams'].map { |program_stream| program_stream['trackings'].size }).to include 2
      end
    end
  end
end
