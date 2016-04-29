describe Family, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:cases) }
  it { is_expected.not_to have_many(:tranings) }
end

describe Family, 'scopes' do
  let(:province) { create(:province) }
  let!(:family){ create(:family, family_type: 'kinship', province: province)}
  let!(:other_family){ create(:family, family_type: 'foster')}

  context 'name like' do
    let!(:families){ Family.name_like(family.name.downcase) }
    it 'should include record have family name like' do
      expect(families).to include(family)
    end
    it 'should not include record not have family name like' do
      expect(families).not_to include(other_family)
    end
  end

  context 'caregiver information like' do
    let!(:families){ Family.caregiver_information_like(family.caregiver_information.downcase) }
    it 'should include record have caregiver information like' do
      expect(families).to include(family)
    end
    it 'should not include record not have caregiver information like' do
      expect(families).not_to include(other_family)
    end
  end

  context 'address like' do
    let!(:families){ Family.address_like(family.address.downcase) }
    it 'should include record have address like' do
      expect(families).to include(family)
    end
    it 'should not include record not address like' do
      expect(families).not_to include(other_family)
    end
  end

  context 'kinship' do
    it 'should include kinship type ' do
      expect(Family.kinship).to include(family)
    end
    it 'should not include not kinship type ' do
      expect(Family.kinship).not_to include(other_family)
    end
  end

  context 'foster' do
    it 'should include foster type' do
      expect(Family.foster).to include(other_family)
    end
    it 'should not include not foster type' do
      expect(Family.foster).not_to include(family)
    end
  end

  context 'province is' do
    subject{ Family.province_is }

    it 'should include province' do
      province_array = [province.name, province.id]
      is_expected.to include(province_array)
    end
  end
end

describe Family, 'methods' do

  context 'member count' do
    let!(:family){ create(:family,
      male_adult_count: 1,
      female_adult_count: 1
    ) }
    it 'should return total family member' do
      expect(family.member_count).to eq(2)
    end
  end
end
