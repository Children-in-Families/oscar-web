require 'spec_helper'

describe Api::V1::ClientTasks::TasksController, type: :request do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  let(:user) { create(:user) }
  let!(:client) { create(:client, users: [user]) }
  let!(:domains) { create_list(:domain, 12) }
  let!(:task) { create(:task, client: client) }

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
          task = { format: 'json', task: { user_ids: client.user_ids, domain_id: domains.sample.id, name: FFaker::Lorem.paragraph, completion_date: 1.month.from_now} }
          post "/api/v1/clients/#{client.id}/tasks", task, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when try to create task without domain' do
        before do
          task = { format: 'json', task: { user_ids: client.user_ids, name: FFaker::Lorem.paragraph, completion_date: 1.month.from_now}  }
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

  describe 'PUT #update' do
    context 'when user not loged in' do
      before do
        put "/api/v1/clients/#{client.id}/tasks/#{task.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to update task' do
        before do
          task_params = { format: 'json', task: { user_ids: client.user_ids, completion_date: 1.month.from_now} }
          put "/api/v1/clients/#{client.id}/tasks/#{task.id}", task_params, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user not loged in' do
      before do
        delete "/api/v1/clients/#{client.id}/tasks/#{task.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try to delete task' do
        before do
          delete "/api/v1/clients/#{client.id}/tasks/#{task.id}", @auth_headers
        end

        it 'should be return status 204' do
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end
end
