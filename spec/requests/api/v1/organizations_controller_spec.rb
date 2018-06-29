require 'spec_helper'

RSpec.describe Api::V1::OrganizationsController, type: :request do

  describe 'GET #index' do

    before do
      get '/api/v1/organizations'
    end

    it 'should be return status 200' do
      expect(response).to have_http_status(:success)
    end

    it 'should be returns the organizations with the correct data' do
      expect(json['organizations'].size).to eq 4
    end
  end
end
