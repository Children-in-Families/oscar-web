describe Call, 'associations' do
  it { is_expected.to belong_to(:referee) }
end

describe Call, 'validations' do
  it { is_expected.to validate_presence_of(:receiving_staff_id) }
  it { is_expected.to validate_presence_of(:start_datetime) }
  it { is_expected.to validate_presence_of(:end_datetime) }
  it { is_expected.to validate_presence_of(:call_type) }
  # it { is_expected.to validate_inclusion_of(:call_type).in_array(Call.call_types.values)}

  context 'call_type' do
    let!(:referee) { create(:referee) }
    let(:call){ Factory.build(:call, referee: referee, call_type: I18n.t('calls.type.case_action_required')) }
    it 'valid' do
      # pause here
    #   expect(call).to be_valid
    #   # expect(custom_csi.errors.full_messages).to include('Assessment tool must be enable in setting')
    end
  end
end
