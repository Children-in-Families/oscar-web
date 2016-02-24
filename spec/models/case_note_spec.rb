require 'rails_helper'

RSpec.describe CaseNote, 'associations', type: :model do
  it { is_expected.to belong_to(:case_worker) }
  it { is_expected.to belong_to(:kinship_or_foster_care_case) }
end

describe CaseNote, 'class methods' do
  let(:province)    { create(:province, code: '01', name: 'PNameLao') }
  let(:case_worker) { create(:case_worker, province: province) }
  let(:client)      { create(:client, first_name: 'Bunhouth', last_name: 'Suong', referral_recieved_by: case_worker) }
  let(:family)      { create(:family, province: province) }
  let(:kinship_or_foster_care_case) { create(:kinship_or_foster_care_case, :kc, family: family, case_worker: case_worker, client: client) }

  let(:assessment)  { create(:assessment, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: '22/6/2015') }
  let(:case_note)   { create(:case_note, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: '22/12/2015') }

  before do
    assessment
    case_note
  end

  describe '.next_case_note_date_by_kc_fc_case' do
    it 'returns next case note date' do
      case_note_date = CaseNote.next_case_note_date_by_kc_fc_case(kinship_or_foster_care_case)
      date = '22/02/2016'

      expect(case_note_date).to eq date.to_date
    end
  end

end
