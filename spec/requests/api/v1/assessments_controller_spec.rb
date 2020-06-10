require 'spec_helper'

describe Api::V1::AssessmentsController, type: :request do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end

  let(:user) { create(:user) }
  let!(:client) { create(:client, users: [user]) }
  let!(:domain) { create(:domain) }
  let(:score) { [1, 2, 3, 4].sample }

  describe 'POST #creates' do
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

  describe 'PUT #update' do
    let!(:assessment) { create(:assessment, client: client) }
    let!(:assessment_domains) { create_list(:assessment_domain, 12, assessment: assessment) }

    context 'when user not loged in' do
      before do
        put "/api/v1/clients/#{client.id}/assessments/#{assessment.id}"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
      end

      context 'when try update assessment' do
        before do
          assessment_params = { format: 'json', assessment: { assessment_domains_attributes: {'0' => { id: assessment_domains[0].id, domain_id: domain.id, score: score, reason: FFaker::Lorem.paragraph, goal: "Testing Goal"} } } }
          put "/api/v1/clients/#{client.id}/assessments/#{assessment.id}", assessment_params, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        xit 'should be return correct data' do
          expect(json['assessment']['assessment_domains'].map{ |ad| ad['goal'] }).to include("Testing Goal")
        end
      end

      context 'when try update assessment without domain' do
        before do
          assessment_params_ = { format: 'json', assessment: { assessment_domains_attributes: {'0' => {score: score, reason: FFaker::Lorem.paragraph, goal: FFaker::Lorem.paragraph} } } }
          put "/api/v1/clients/#{client.id}/assessments/#{assessment.id}", assessment_params_, @auth_headers
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
