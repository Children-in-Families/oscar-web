require 'rails_helper'

describe Converter do
  let(:province)    { create(:province, code: '01', name: 'PNameLao') }
  let(:case_worker) { create(:case_worker, province: province) }
  let(:client)      { create(:client, first_name: 'Bunhouth', last_name: 'Suong', referral_recieved_by: case_worker) }
  let(:family)      { create(:family, province: province) }
  let(:kinship_or_foster_care_case) { create(:kinship_or_foster_care_case, :kc, family: family, case_worker: case_worker, client: client) }

  before do
    create(:assessment, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: 6.months.ago)
    create(:case_note, kinship_or_foster_care_case: kinship_or_foster_care_case, case_worker: case_worker, date: '22/12/2015')
  end

  context 'client' do
    it 'should respond with hash format' do
      expect(Converter.convert(client)).to include(:first_name => 'Bunhouth', :emergency_care_case => nil)
    end
  end

  context 'case worker' do
    it 'should respond with hash format' do
      converter = Converter.convert(case_worker)
      expect(converter[:clients]).not_to be_empty
    end
  end
end
