describe Call, 'associations' do
  it { is_expected.to belong_to(:caller) }
end

describe Call, 'validations' do
  it { is_expected.to validate_presence_of(:receiving_staff_id) }
  it { is_expected.to validate_presence_of(:start_datetime) }
  it { is_expected.to validate_presence_of(:end_datetime) }
  it { is_expected.to validate_presence_of(:call_type) }
  it { is_expected.to validate_inclusion_of(:call_type).in_array(Call::CALL_TYPE)}
end