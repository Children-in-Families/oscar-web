describe Domain, 'associations' do
  it { is_expected.to belong_to(:domain_group) }
  it { is_expected.to have_many(:assessment_domains).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:tasks).dependent(:restrict_with_error)}
end

describe Domain, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:identity) }
  it { is_expected.to validate_presence_of(:domain_group) }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:custom_domain) }
  it { is_expected.to validate_uniqueness_of(:identity).case_insensitive.scoped_to(:custom_domain) }
end

describe Domain, 'methods' do
  let!(:domain){
    create(:domain, description: 'Food', local_description: 'អាហារ',
                    score_1_definition: 'Poor', score_2_definition: 'Good', score_3_definition: 'Better', score_4_definition: 'Best',
                    score_1_local_definition: 'ខ្សោយ', score_2_local_definition: 'ល្អ', score_3_local_definition: 'ល្អបង្គួរ', score_4_local_definition: 'ល្អណាស់'
          )}
  context 'convert_identity' do
    it 'should return identity with underscore' do
      expect(domain.convert_identity).to eq(domain.identity.downcase.parameterize('_'))
    end
  end
  context 'translate_description' do
    it 'returns locale description when user change language to something else' do
      I18n.locale = [:km, :my].sample
      expect(domain.translate_description).to eq('អាហារ')
    end
    it 'returns description when user change language to English' do
      I18n.locale = :en
      expect(domain.translate_description).to eq('Food')
    end
  end
  context 'translate_score_1_definition' do
    it 'returns score 1 local definition when user change language to something else' do
      I18n.locale = [:km, :my].sample
      expect(domain.translate_score_1_definition).to eq('ខ្សោយ')
    end
    it 'returns score 1 definition when user change language to English' do
      I18n.locale = :en
      expect(domain.translate_score_1_definition).to eq('Poor')
    end
  end
  context 'translate_score_2_definition' do
    it 'returns score 2 local definition when user change language to something else' do
      I18n.locale = [:km, :my].sample
      expect(domain.translate_score_2_definition).to eq('ល្អ')
    end
    it 'returns score 2 definition when user change language to English' do
      I18n.locale = :en
      expect(domain.translate_score_2_definition).to eq('Good')
    end
  end
  context 'translate_score_3_definition' do
    it 'returns score 3 local definition when user change language to something else' do
      I18n.locale = [:km, :my].sample
      expect(domain.translate_score_3_definition).to eq('ល្អបង្គួរ')
    end
    it 'returns score 3 definition when user change language to English' do
      I18n.locale = :en
      expect(domain.translate_score_3_definition).to eq('Better')
    end
  end
  context 'translate_score_4_definition' do
    it 'returns local score 4 local definition when user change language to something else' do
      I18n.locale = [:km, :my].sample
      expect(domain.translate_score_4_definition).to eq('ល្អណាស់')
    end
    it 'returns score 4 definition when user change language to English' do
      I18n.locale = :en
      expect(domain.translate_score_4_definition).to eq('Best')
    end
  end
end

describe Domain, 'scopes' do
  let!(:domain){ create(:domain, custom_domain: false) }
  let!(:custom_domain){ create(:domain, custom_domain: true) }

  it '.csi_domains' do
    domains = Domain.csi_domains
    expect(domains).to include(domain)
    expect(domains).not_to include(custom_domain)
  end

  it '.custom_csi_domains' do
    domains = Domain.custom_csi_domains
    expect(domains).to include(custom_domain)
    expect(domains).not_to include(domain)
  end
end
