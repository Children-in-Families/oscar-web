require 'rails_helper'

RSpec.describe KinshipOrFosterCareCase, 'associations', type: :model do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:case_worker) }

  it { is_expected.to have_many(:assessments) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:contracts) }
end

RSpec.describe KinshipOrFosterCareCase, 'instance method', type: :model do
  let(:province)    { create(:province, code: '01', name: 'PNameLao') }
  let(:case_worker) { create(:case_worker, province: province) }
  let(:client)      { create(:client, first_name: 'Bunhouth', last_name: 'Suong', referral_recieved_by: case_worker) }
  let(:family)      { create(:family, province: province) }
  let(:kinship_or_foster_care_case) { create(:kinship_or_foster_care_case, :kc, family: family, case_worker: case_worker, client: client) }

  before do
    @date = { assessment: 6.months.ago, case_note: 2.weeks.ago }
  end

  context 'when have assessments and case notes' do
    before do
      create(:assessment, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: @date[:assessment])
      create(:case_note, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: @date[:case_note])
    end

    it 'returns next appointment date' do
      next_appointment_date = @date[:case_note].to_date + 1.month
      expect(kinship_or_foster_care_case.next_appointment_date).to eq next_appointment_date
    end
  end

  context 'when have assessments and no case note' do
    before do
      create(:assessment, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: @date[:assessment])
    end

    it 'returns next appointment date' do
      next_appointment_date = @date[:assessment].to_date + 1.month
      expect(kinship_or_foster_care_case.next_appointment_date).to eq next_appointment_date
    end
  end

  context 'when no assessment' do
    it 'return nil if no assessment' do
      expect(kinship_or_foster_care_case.next_appointment_date).to eq nil
    end
  end
end
