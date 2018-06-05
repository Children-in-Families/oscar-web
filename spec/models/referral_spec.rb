describe Referral, 'associations' do
  it { is_expected.to belong_to(:client) }
end

describe Referral, 'validations' do
  it { is_expected.to validate_presence_of(:client_name) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:date_of_referral) }
  it { is_expected.to validate_presence_of(:referred_from) }
  it { is_expected.to validate_presence_of(:referred_to) }
  it { is_expected.to validate_presence_of(:referral_reason) }
  it { is_expected.to validate_presence_of(:name_of_referee) }
  it { is_expected.to validate_presence_of(:referral_phone) }
  it { is_expected.to validate_presence_of(:referee_id) }
  it { is_expected.to validate_presence_of(:consent_form) }
end

describe Referral, 'callbacks' do
  context 'before_save' do
    context 'set_referred_from' do

    end
  end

  context 'after_save' do
    context 'make_a_copy_to_target_ngo' do

    end
  end

  context 'after_create' do
    context 'email_referrral_client' do

    end
  end
end

describe Referral, 'scopes' do
  context 'received' do

  end

  context 'unsaved' do

  end
end
