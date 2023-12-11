require 'spec_helper'

describe Api::V1::CaseNotesController, type: :request do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end

  let(:user) { create(:user) }
  let!(:client) { create(:client, users: [user], code: rand(1000..2000).to_s) }
  let(:assessment) { create(:assessment) }
  let!(:assessment_domain) { create_list(:assessment_domain, 12, assessment: assessment) }
  let!(:tasks) { create_list(:task, 2, completed: true, case_note_domain_group: nil, domain: Domain.first, user: user, client: client) }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/clients/#{client.id}/case_notes"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        @domain_group = DomainGroup.all.sample
      end

      context 'when try to create case note with incompleted tasks' do
        before do
          case_note = { format: 'json', case_note: { meeting_date: Time.now, attendee: FFaker::Name.name, interaction_type: 'Visit', case_note_domain_groups_attributes: {'0' => {note: FFaker::Lorem.paragraph, domain_group_id: @domain_group.id}} } }

          post "/api/v1/clients/#{client.id}/case_notes", case_note, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when try to create case note with completed task' do
        before do
          case_note = { format: 'json', case_note: { meeting_date: Time.now, attendee: FFaker::Name.name, interaction_type: 'Visit', case_note_domain_groups_attributes: {'0' => {note: FFaker::Lorem.paragraph, domain_group_id: @domain_group.id, task_ids: tasks.map(&:id)}} } }
          post "/api/v1/clients/#{client.id}/case_notes", case_note, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should be update tasks' do
          expect(Task.first.completed).to be true
          expect(Task.first.user_id).to eq(user.id)
        end
      end

      context 'when try to create case note without domain group' do
        before do
          case_note = { format: 'json', case_note: { meeting_date: Time.now, attendee: FFaker::Name.name, interaction_type: 'Visit', case_note_domain_groups_attributes: {'0' => {note: FFaker::Lorem.paragraph}} } }
          post "/api/v1/clients/#{client.id}/case_notes", case_note, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return validation message' do
          expect(json['case_note_domain_groups.domain_group']).to eq ['can\'t be blank']
        end
      end
    end
  end

  describe 'PUT #update' do
    let!(:case_note) { create(:case_note, client: client) }
    let!(:case_note_domain_groups) { create(:case_note_domain_group, case_note: case_note) }

    context 'when user not loged in' do
      before do
        put "/api/v1/clients/#{client.id}/case_notes/#{case_note.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do

      before do
        sign_in(user)
        @domain_group = DomainGroup.all.sample
      end

      context 'when try to update case note with incompleted tasks' do
        before do
          case_note_params = { format: 'json', case_note: { meeting_date: Time.now, case_note_domain_groups_attributes: {'0' => {note: FFaker::Lorem.paragraph, domain_group_id: @domain_group.id}} } }
          put "/api/v1/clients/#{client.id}/case_notes/#{case_note.id}", case_note_params, @auth_headers
        end

        xit 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when try to update case note with completed task' do
        before do
          case_note_params = { format: 'json', case_note: { meeting_date: Time.now, case_note_domain_groups_attributes: {'0' => {note: FFaker::Lorem.paragraph, domain_group_id: @domain_group.id, task_ids: tasks.map(&:id)}} } }
          put "/api/v1/clients/#{client.id}/case_notes/#{case_note.id}", case_note_params, @auth_headers
        end

        xit 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        xit 'should be update tasks' do
          expect(Task.first.completed).to be true
        end
      end

      context 'when try to update case note without domain group' do
        before do
          case_note_params = { format: 'json', case_note: { meeting_date: Time.now, case_note_domain_groups_attributes: {'0' => {note: FFaker::Lorem.paragraph}} } }
          put "/api/v1/clients/#{client.id}/case_notes/#{case_note.id}", case_note_params, @auth_headers
        end

        xit 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        xit 'should be return validation message' do
          expect(json['case_note_domain_groups.domain_group']).to eq ['can\'t be blank']
        end
      end
    end
  end
end
