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
  let(:client_1){ create(:client, :accepted) }
  let(:referral_1){ build(:referral, referred_from: 'Organization Testing', referred_to: 'demo', client: client_1, slug: client_1.slug) }
  before { referral_1.save }
  context 'before_save' do
    context '#set_referred_from' do
      it 'to short_name of tenant' do
        expect(referral_1.referred_from).to eq('app')
      end
    end
  end

  context 'after_save' do
    context '#make_a_copy_to_target_ngo' do
      it 'in Demo NGO' do
        Organization.switch_to 'demo'
        expect(Referral.count).to eq(1)
        expect(Referral.first.slug).to eq(referral_1.slug)
        expect(Referral.first.client_id).to eq(nil)
        expect(Referral.first.client_name).to eq(referral_1.client_name)
        expect(Referral.first.referred_from).to eq(referral_1.referred_from)
        expect(Referral.first.referred_to).to eq(referral_1.referred_to)
        expect(Referral.first.name_of_referee).to eq(referral_1.name_of_referee)
        expect(Referral.first.referral_phone).to eq(referral_1.referral_phone)
        expect(Referral.first.referee_id).to eq(referral_1.referee_id)
        expect(Referral.first.referral_reason).to eq(referral_1.referral_reason)
        expect(Referral.first.date_of_referral).to eq(referral_1.date_of_referral)
        expect(Referral.first.saved).to eq(referral_1.saved)
        expect(Referral.first.consent_form.file.original_filename).to eq(referral_1.consent_form.file.original_filename)
        Organization.switch_to 'app'
      end
    end
  end

  context 'after_create' do
    context '#email_referrral_client' do
      let!(:user){ create(:user, :admin) }
      before do
        Organization.switch_to 'demo'
        FactoryGirl.create(:user, :admin)
        Organization.switch_to 'app'
      end
      subject(:referral_email_notification) { ActionMailer::Base.deliveries }
      it 'notify target NGO of new referral' do
        expect(EmailReferralClientWorker.jobs.size).to eq(1)
        expect(EmailReferralClientWorker).to be_processed_in 'send_email'
      end
    end
  end
end

describe Referral, 'scopes' do
  let!(:referral_1){ create(:referral, referred_from: 'Organization Testing', referred_to: 'demo') }
  context '.received' do
    it 'not return external referral' do
      expect(Referral.received.ids).not_to include(referral_1.id)
    end
  end

  context '.unsaved' do
    it 'returns external referral which has not been saved by target NGO' do
      expect(Referral.unsaved.ids).to include(referral_1.id)
    end
  end
end
