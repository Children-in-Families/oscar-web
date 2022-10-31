describe Donor do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  describe Donor, 'associations' do
    it { is_expected.to have_many(:sponsors).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:clients).through(:sponsors) }
  end

  describe Donor, 'validation' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:code).case_insensitive }

    it 'validates uniqueness of name case sensitivity if code is blank' do
      FactoryBot.create(:donor, name: 'NGO A')
      valid_donor   = Donor.new(name: 'NGO B')
      invalid_donor = Donor.new(name: 'ngo a')
      expect(valid_donor).to be_valid
      expect(invalid_donor).to be_invalid
    end

    it 'validates uniqueness of name base on code if code exists' do
      FactoryBot.create(:donor, name: 'NGO A', code: 'A')
      valid_donor   = Donor.new(name: 'NGO A', code: 'B')
      invalid_donor = Donor.new(name: 'NGO A', code: 'A')
      expect(valid_donor).to be_valid
      expect(invalid_donor).to be_invalid
    end
  end

  describe Donor, 'scopes' do
    context 'has clients' do
      let!(:donor) { create(:donor) }
      let!(:other_donor) { create(:donor) }
      let!(:client) { create(:client, donor_ids: [donor.id]) }
      subject { Donor.has_clients }

      it 'should include donor that has clients' do
        is_expected.to include(donor)
      end
      it 'should not include donor that has no clients' do
        is_expected.not_to include(other_donor)
      end
    end
  end
end