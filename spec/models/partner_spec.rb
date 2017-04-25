describe Partner, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:cases) }
  it { is_expected.to have_many(:partner_custom_fields).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:partner_custom_fields) }
end

describe Partner, 'scopes' do
  let!(:partner){ create(:partner)}
  let!(:other_partner){ create(:partner,
    name: 'Example Partner',
    contact_person_name: 'Example Person',
    contact_person_mobile: '+1234567890',
    engagement: 'Example Engagement',
    background: 'Example Background',
    address: 'Example Address'
  ) }
  let!(:ngo_partner){ create(:partner, organisation_type: 'NGO') }
  let!(:local_goverment_partner){ create(:partner, organisation_type: 'Local Goverment') }
  let!(:church_partner){ create(:partner, organisation_type: 'Church') }
  context 'name like' do
    let!(:partners){ Partner.name_like(partner.name.downcase) }
    it 'should include partner name like' do
      expect(partners).to include(partner)
    end
    it 'should not include partner not name like' do
      expect(partners).not_to include(other_partner)
    end
  end

  context 'contact person name like' do
    let!(:partners){ Partner.contact_person_name_like(partner.contact_person_name.downcase) }
    it 'should include contact person name like' do
      expect(partners).to include(partner)
    end
    it 'should not include contact person not name like' do
      expect(partners).not_to include(other_partner)
    end
  end

  context 'contact person mobile like' do
    let!(:partners){ Partner.contact_person_mobile_like(partner.contact_person_mobile) }
    it 'should include contact person mobile like' do
      expect(partners).to include(partner)
    end
    it 'should not include contact person not mobile like' do
      expect(partners).not_to include(other_partner)
    end
  end

  context 'organisation type are' do
    let!(:organisation_type){ Partner.organisation_type_are }
    it 'should include organisation type' do
      expect(organisation_type).to include(partner.organisation_type)
    end
  end

  context 'affiliation like' do
    let!(:partners){ Partner.engagement_like(partner.engagement) }
    it 'should include engagement like' do
      expect(partners).to include(partner)
    end
    it 'should not include not engagement like' do
      expect(partners).not_to include(other_partner)
    end
  end

  context 'background like' do
    let!(:partners){ Partner.background_like(partner.background.downcase) }
    it 'should include background like' do
      expect(partners).to include(partner)
    end
    it 'should not include not background like' do
      expect(partners).not_to include(other_partner)
    end
  end

  context 'address like' do
    let!(:partners){ Partner.address_like(partner.address.downcase) }
    it 'should include address like' do
      expect(partners).to include(partner)
    end
    it 'should not include not address like' do
      expect(partners).not_to include(other_partner)
    end
  end

  context 'province are' do
    let!(:province_are){ Partner.province_are }
    it 'should include province' do
      expect(province_are).to include([partner.province.name, partner.province.id])
    end
  end

  context 'NGO' do
    subject{ Partner.NGO }
    it 'should include ngo' do
      is_expected.to include(ngo_partner)
    end
    it 'should not include not ngo' do
      is_expected.not_to include(local_goverment_partner)
      is_expected.not_to include(church_partner)
    end
  end

  context 'local goverment' do
    subject{ Partner.local_goverment }
    it 'should include ngo' do
      is_expected.to include(local_goverment_partner)
    end
    it 'should not include not ngo' do
      is_expected.not_to include(ngo_partner)
      is_expected.not_to include(church_partner)
    end
  end

  context 'Church' do
    subject{ Partner.church }
    it 'should include ngo' do
      is_expected.to include(church_partner)
    end
    it 'should not include not ngo' do
      is_expected.not_to include(local_goverment_partner)
      is_expected.not_to include(ngo_partner)
    end
  end
end
