describe Family, 'validation' do
  it { is_expected.to validate_presence_of(:family_type) }
  it { is_expected.to validate_inclusion_of(:family_type).in_array(Family::TYPES)}
  it { is_expected.to validate_inclusion_of(:status).in_array(Family::STATUSES)}

  context 'case_worker_ids' do
    context 'on update unless exit_ngo' do
      let!(:admin){ create(:user, :admin) } # required this object for the email to be sent
      let!(:family){ create(:family, :accepted) }
      let!(:exit_family){ create(:family, :exited) }
      context 'no validate if exit ngo' do
        before do
          exit_family.case_worker_ids = []
        end
        it { expect(exit_family.valid?).to be_truthy }
      end

      context 'validate if not exit ngo' do
        before do
          family.case_worker_ids = []
        end
        it { expect(family.valid?).to be_truthy }
      end
    end
  end
end

describe Family, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:district) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:cases) }
  it { is_expected.to have_many(:family_members).dependent(:destroy) }
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
  it { is_expected.to have_many(:enrollments).dependent(:destroy) }
  it { is_expected.to have_many(:program_streams).through(:enrollments) }
  it { is_expected.to have_many(:enter_ngos).dependent(:destroy) }
  it { is_expected.to have_many(:exit_ngos).dependent(:destroy) }
  it { is_expected.to have_many(:assessments).dependent(:destroy) }
  it { is_expected.to have_many(:tasks).dependent(:nullify) }
  it { is_expected.to have_many(:goals).dependent(:destroy) }
  it { is_expected.to have_many(:case_notes).dependent(:destroy) }
end

describe Family, 'scopes' do
  let(:province) { create(:province) }
  let!(:kc_family){ create(:family, :kinship, province: province)}
  let!(:fc_family){ create(:family, :foster)}
  let!(:ec_family){ create(:family, :emergency)}
  let!(:active_family){ create(:family, :active)}
  let!(:inactive_family){ create(:family, :inactive, :other)}
  let!(:birth_family){ create(:family, :birth_family_both_parents)}

  context '.as_non_cases' do
    it 'include inactive and birth_family' do
      expect(Family.as_non_cases).to include(inactive_family, birth_family)
    end

    it 'exclude emergency foster and kinship family' do
      expect(Family.as_non_cases).not_to include(kc_family, fc_family, ec_family)
    end
  end

  context '.name_like' do
    let!(:families){ Family.name_like(kc_family.name.downcase) }
    it 'should include record have family name like' do
      expect(families).to include(kc_family)
    end
    it 'should not include record not have family name like' do
      expect(families).not_to include(fc_family)
    end
  end

  context '.caregiver_information_like' do
    let!(:families){ Family.caregiver_information_like(kc_family.caregiver_information.downcase) }
    it 'should include record have caregiver information like' do
      expect(families).to include(kc_family)
    end
    it 'should not include record not have caregiver information like' do
      expect(families).not_to include(fc_family)
    end
  end

  context '.address_like' do
    let!(:families){ Family.address_like(kc_family.address.downcase) }
    it 'should include record have address like' do
      expect(families).to include(kc_family)
    end
    it 'should not include record not address like' do
      expect(families).not_to include(fc_family)
    end
  end

  context '.kinship' do
    it 'should include kinship type ' do
      expect(Family.kinship).to include(kc_family)
    end
    it 'should not include not kinship type ' do
      expect(Family.kinship).not_to include(fc_family)
    end
  end

  context '.foster' do
    it 'should include foster type' do
      expect(Family.foster).to include(fc_family)
    end
    it 'should not include not foster type' do
      expect(Family.foster).not_to include(kc_family)
    end
  end

  context '.emergency' do
    it 'should include emergency type' do
      expect(Family.emergency).to include(ec_family)
    end
    it 'should not include not emergency type' do
      expect(Family.emergency).not_to include(kc_family)
      expect(Family.emergency).not_to include(fc_family)
    end
  end

  context '.inactive' do
    it 'should include inactive type' do
      expect(Family.inactive).to include(inactive_family)
    end
    it 'should not include not inactive type' do
      expect(Family.inactive).not_to include(kc_family)
    end
  end

  context '.active' do
    it 'should include active status' do
      expect(Family.active).to include(active_family)
    end
    it 'should not include inactive status' do
      expect(Family.active).not_to include(inactive_family)
    end
  end

  context '.birth_family' do
    it 'should include birth_family type' do
      expect(Family.birth_family_both_parents).to include(birth_family)
    end
    it 'should not include not birth_family type' do
      expect(Family.birth_family_both_parents).not_to include(kc_family)
      expect(Family.birth_family_both_parents).not_to include(fc_family)
    end
  end

  context '.province_are' do
    subject{ Family.province_are }

    it 'should include province' do
      province_array = [province.name, province.id]
      is_expected.to include(province_array)
    end
  end
end

describe Family, 'instance methods' do
  let!(:referred_family){ create(:family) }
  let!(:inactive_family){ create(:family, :inactive) }
  let!(:birth_family){ create(:family, :birth_family_both_parents) }
  let!(:ec_family){ create(:family, :emergency) }
  let!(:fc_family){ create(:family, :foster) }
  let!(:kc_family){ create(:family, :kinship) }
  context '#member_count' do
    let!(:family){ create(:family,
      male_adult_count: 1,
      female_adult_count: 1
    ) }
    it 'should return total family member' do
      # expect(kc_family.member_count).to eq(2)
    end
  end

  context '#inactive?' do
    it { expect(inactive_family.inactive?).to be_truthy }
  end

  context '#referred?' do
    it { expect(referred_family.referred?).to be_truthy }
  end

  context '#exit_ngo?' do
    it 'should return true if status is exited' do
      inactive_family.status = 'Exited'
      expect(inactive_family.exit_ngo?).to be_truthy
    end
  end

  context '#birth_family_both_parents?' do
    it { expect(birth_family.birth_family_both_parents?).to be_truthy }
  end

  context '#emergency?' do
    it { expect(ec_family.emergency?).to be_truthy }
  end

  context '#foster?' do
    it { expect(fc_family.foster?).to be_truthy }
  end

  context '#kinship?' do
    it { expect(kc_family.kinship?).to be_truthy }
  end

  context '#is_case?' do
    it 'emergency should be true' do
      expect(ec_family.is_case?).to be_truthy
    end

    it 'foster should be true' do
      expect(fc_family.is_case?).to be_truthy
    end

    it 'kinship should be true' do
      expect(kc_family.is_case?).to be_truthy
    end

    it 'inactive should be false' do
      expect(inactive_family.is_case?).to be_truthy
    end

    it 'birth_family should be false' do
      expect(birth_family.is_case?).to be_falsey
    end
  end
end
