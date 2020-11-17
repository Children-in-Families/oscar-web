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
        expect(subject.client_quantitative_case_histories.first.object).to include(quantitative_case.attributes.slice('id', 'quantitative_type_id', 'value'))
      end

      it 'creates agency client history' do
        expect(subject.agency_client_histories.first.object).to include(agency.attributes.slice('agencies_clients_count', 'description', 'id', 'name', ))
      end

      it 'creates sponsor history' do
        expect(subject.sponsor_histories.first.object).to include(donor.attributes.slice('code', 'description', 'id', 'name'))
      end

      it 'creates case client history' do
        expect(subject.case_client_histories.first.object).to include(client_case.attributes.slice('carer_address', 'carer_names', 'carer_phone_number', ))
      end

      it 'create client family history' do
        expect(subject.client_family_histories.first.object).to include(client_case.family.attributes.slice('address', 'caregiver_information', 'user_id', 'village_id'))
      end
    end
  end
end
