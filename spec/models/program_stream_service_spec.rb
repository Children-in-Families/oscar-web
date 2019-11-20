RSpec.describe ProgramStreamService, 'associations' do
  it { is_expected.to belong_to(:program_stream) }
  it { is_expected.to belong_to(:service) }
end
