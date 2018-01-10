require 'spec_helper'

RSpec.describe Api::V1::ProgramStreamsController, type: :request do
  let(:user) { create(:user) }
  let!(:complete_programs) { create_list(:program_stream, 2, tracking_required: true) }
  let!(:incomplete_program){ create(:program_stream) }

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
        get '/api/v1/program_streams', @auth_headers
      end

      it 'should be return status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'should be returns the program_stream with the correct data' do
        expect(json['program_streams']).not_to be_empty
        expect(json['program_streams'].size).to eq(2)
        expect(json['program_streams'].map{|a| a['id'] }).to include(complete_programs.first.id, complete_programs.last.id)
        expect(json['program_streams'].map{|a| a['id'] }).not_to include(incomplete_program.id)
      end
    end
  end
end
