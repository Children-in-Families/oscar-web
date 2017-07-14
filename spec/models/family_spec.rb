describe Family, 'validation' do
  it { is_expected.to validate_inclusion_of(:family_type).in_array(Family::FAMILY_TYPE)}
end

describe Family, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:cases) }
  it { is_expected.not_to have_many(:tranings) }
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
end

describe Family, 'scopes' do
  let(:province) { create(:province) }
  let!(:family){ create(:family, family_type: 'kinship', province: province)}
  let!(:other_family){ create(:family, family_type: 'foster')}
  let!(:emergency_family){ create(:family, family_type: 'emergency')}
  let!(:inactive_family){ create(:family, family_type: 'inactive')}
  let!(:birth_family){ create(:family, family_type: 'birth_family')}

  context 'as_non_cases' do
    it { expect(Family.as_non_cases).to include(inactive_family, birth_family) }
    it { expect(Family.as_non_cases).not_to include(family, other_family, emergency_family) }
  end

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

  context 'emergency' do
    it 'should include emergency type' do
      expect(Family.emergency).to include(emergency_family)
    end
    it 'should not include not emergency type' do
      expect(Family.emergency).not_to include(family)
      expect(Family.emergency).not_to include(other_family)
    end
  end

  context 'inactive' do
    it 'should include inactive type' do
      expect(Family.inactive).to include(inactive_family)
    end
    it 'should not include not inactive type' do
      expect(Family.inactive).not_to include(family)
      expect(Family.inactive).not_to include(other_family)
    end
  end

  context 'birth_family' do
    it 'should include birth_family type' do
      expect(Family.birth_family).to include(birth_family)
    end
    it 'should not include not birth_family type' do
      expect(Family.birth_family).not_to include(family)
      expect(Family.birth_family).not_to include(other_family)
    end
  end

  context 'province are' do
    subject{ Family.province_are }

    it 'should include province' do
      province_array = [province.name, province.id]
      is_expected.to include(province_array)
    end
  end
end

describe Family, 'methods' do
  let!(:inactive_family){ create(:family, family_type: 'inactive')}
  let!(:birth_family){ create(:family, family_type: 'birth_family')}
  context 'member count' do
    let!(:family){ create(:family,
      male_adult_count: 1,
      female_adult_count: 1
    ) }
    it 'should return total family member' do
      expect(family.member_count).to eq(2)
    end
  end

  context 'inactive?' do
    it { expect(inactive_family.inactive?).to be true }
  end

  context 'birth_family?' do
    it { expect(birth_family.birth_family?).to be true }
  end
end
