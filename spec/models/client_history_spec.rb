require 'rails_helper'

RSpec.describe ClientHistory do
  describe CustomAssessmentSetting, 'methods' do
    context '#create_client_quantitative_case_history' do
      let!(:client){ create(:client) }
      let!(:quantitative_case){ create(:quantitative_case, clients: [client]) }
      let!(:agency){ create(:agency, clients: [client]) }
      let!(:donor){ create(:donor, clients: [client]) }
      let!(:client_case){ create(:case, client: client) }

      subject { ClientHistory.initial(client) }
      it 'creates client quantitative_case history' do
        expect(subject.client_quantitative_case_histories.first.object).to eq(quantitative_case.attributes)
      end

      it 'creates agency client history' do
        expect(subject.agency_client_histories.first.object).to eq(agency.attributes)
      end

      it 'creates sponsor history' do
        expect(subject.sponsor_histories.first.object).to eq(donor.attributes)
      end

      it 'creates case client history' do
        expect(subject.case_client_histories.first.object).to eq(client_case.attributes)
      end

      it 'create client family history' do
        expect(subject.client_family_histories.first.object).to eq(client_case.family.attributes)
      end
    end
  end
end
