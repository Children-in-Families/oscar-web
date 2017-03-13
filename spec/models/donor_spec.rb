describe Donor, 'validation' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe Donor, 'associations' do
  it { is_expected.to have_many(:clients) }
end

describe Donor, 'scopes' do
  context 'has clients' do
    let!(:donor) { create(:donor) }
    let!(:other_donor) { create(:donor) }
    let!(:client) { create(:client, donor: donor) }
    subject { Donor.has_clients }

    it 'should include donor that has clients' do
      is_expected.to include(donor)
    end
    it 'should not include donor that has no clients' do
      is_expected.not_to include(other_donor)
    end
  end
end
