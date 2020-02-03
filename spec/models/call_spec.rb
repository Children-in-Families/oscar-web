describe Call, 'associations' do
  it { is_expected.to belong_to(:referee) }
end

describe Call, 'validations' do
  it { is_expected.to validate_presence_of(:receiving_staff_id) }
  it { is_expected.to validate_presence_of(:start_datetime) }
  it { is_expected.to validate_presence_of(:end_datetime) }
  it { is_expected.to validate_presence_of(:call_type) }
  it { is_expected.to validate_inclusion_of(:call_type).in_array(Call::TYPES)}
  it { is_expected.to validate_inclusion_of(:called_before).in_array([true, false])}
  it { is_expected.to validate_inclusion_of(:answered_call).in_array([true, false])}

  context 'information_provided' do
    let!(:referee) { create(:referee) }
    let(:call){ FactoryGirl.build(:call, referee: referee, call_type: 'Seeking Information') }
    it 'invalid' do
      expect(call).to be_invalid
    end
    it 'valid' do
      call.information_provided = "Something"
      expect(call).to be_valid
    end
  end
end

describe Call, 'methods' do
  let!(:seeking_info) { create(:call, call_type: 'Seeking Information', information_provided: "Something" ) }
  let!(:case_not_required) { create(:call, call_type: 'New Referral: Case Action NOT Required' ) }
  context '#seeking_information?' do
    it 'returns true' do
      expect(seeking_info.seeking_information?).to be_truthy
    end
    it 'returns false' do
      expect(case_not_required.seeking_information?).to be_falsey
    end
  end

  context '#case_action_not_required?' do
    it 'returns true' do
      expect(case_not_required.case_action_not_required?).to be_truthy
    end
    it 'returns false' do
      expect(seeking_info.case_action_not_required?).to be_falsey
    end
  end
end

describe Call, 'callbacks' do
  context 'after_save' do
    context 'set_phone_call_id if blank' do
      let!(:call){ create(:call) }
      it 'formats as yyyymmdd-xxxx' do
        id      = call.id.to_s.rjust(4, '0')
        date    = call.date_of_call.strftime('%Y%m%d')
        call_id = "#{date}-#{id}"

        expect(call.phone_call_id).to eq(call_id)
      end
    end
  end
end
