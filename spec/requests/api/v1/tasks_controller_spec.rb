require 'spec_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  let(:user) { create(:user) }
  let!(:client) { create(:client, user: user) }
  let!(:domains) { create_list(:domain, 12) }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/clients/#{client.id}/tasks"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to create task' do
        before do
          task = { format: 'json', task: { domain_id: domains.sample.id, name: FFaker::Lorem.paragraph, completion_date: 1.month.from_now} }
          post "/api/v1/clients/#{client.id}/tasks", task, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when try to create task without domain' do
        before do
          task = { format: 'json', task: {name: FFaker::Lorem.paragraph, completion_date: 1.month.from_now}  }
          post "/api/v1/clients/#{client.id}/tasks", task, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return validation message' do
          expect(json['domain']).to eq ['can\'t be blank']
        end
      end
    end
  end
end
