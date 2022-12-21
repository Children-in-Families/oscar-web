describe Service, 'associations' do
  it { is_expected.to belong_to(:global_service) }
  it { is_expected.to belong_to(:parent).class_name('Service').optional(:true) }
  it { is_expected.to have_many(:children).class_name('Service').with_foreign_key(:parent_id).dependent(:destroy) }

  it { is_expected.to have_many(:program_stream_services).dependent(:destroy) }
  it { is_expected.to have_many(:program_streams).through(:program_stream_services) }
end

describe Service, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
end
