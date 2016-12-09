require 'spec_helper'

RSpec.describe Api::V1::AssessmentsController, type: :request do

  let!(:cif_organization) { Organization.create_and_build_tanent(short_name: 'testing', full_name: 'Testing') }
  let(:user) { create(:user) }
  let!(:client) { create(:client, user: user) }
  let!(:domain) { create(:domain) }
  let(:score) { [1, 2, 3, 4].sample }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/clients/#{client.id}/assessments"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try create assessment' do
        before do
          assessment = { format: 'json', assessment: { assessment_domains_attributes: [{ domain_id: domain.id, score: score, reason: FFaker::Lorem.paragraph, goal: FFaker::Lorem.paragraph}] } }
          post "/api/v1/clients/#{client.id}/assessments", assessment, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when try create assessment without domain' do
        before do
          assessment = { format: 'json', assessment: { assessment_domains_attributes: [{score: score, reason: FFaker::Lorem.paragraph, goal: FFaker::Lorem.paragraph}] } }
          post "/api/v1/clients/#{client.id}/assessments", assessment, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return validation message' do
          expect(json['assessment_domains.domain']).to eq ['can\'t be blank']
        end
      end
    end
  end
end
