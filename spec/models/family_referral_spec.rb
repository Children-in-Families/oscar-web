describe FamilyReferral do
    # before do
    #   allow_any_instance_of(Family).to receive(:generate_random_char).and_return("abcd")
    # end
    # describe FamilyReferral, 'associations' do
    #   it { is_expected.to belong_to(:family) }
    # end
  
    # describe FamilyReferral, 'validations' do
    #   it { is_expected.to validate_presence_of(:name_of_family) }
    #   it { is_expected.to validate_presence_of(:date_of_referral) }
    #   it { is_expected.to validate_presence_of(:referred_from) }
    #   it { is_expected.to validate_presence_of(:referred_to) }
    #   it { is_expected.to validate_presence_of(:referral_reason) }
    #   it { is_expected.to validate_presence_of(:name_of_referee) }
    #   it { is_expected.to validate_presence_of(:referral_phone) }
    #   before { allow(subject).to receive(:slug_exist?).and_return('abcd-123') }
    #   before { allow(subject).to receive(:making_referral?).and_return(true) }
    #   it { is_expected.to validate_presence_of(:referee_id) }
    #   it { is_expected.to validate_presence_of(:consent_form) }
  
    #   context 'consent_form' do
    #     it 'invalid' do
    #       referral = FactoryBot.build(:family_referral, referred_from: 'Organization Testing', consent_form: nil)
    #       expect(referral.valid?).to be_falsey
    #     end
  
    #     it 'valid' do
    #       referral = FactoryBot.build(:family_referral, referred_to: 'app', consent_form: [UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx')))])
    #       expect(referral.valid?).to be_truthy
    #     end
    #   end
    # end
  
    # describe FamilyReferral, 'callbacks' do
    #   context 'before_validation' do
    #     let(:family_1){ create(:family, :active) }
    #     let(:referral_1){ build(:family_referral, referred_from: 'app', referred_to: 'app', family: family_1, slug: family_1.slug) }
    #     before { referral_1.save }
  
    #     context '#set_referred_from' do
    #       it 'to short_name of tenant' do
    #         expect(referral_1.referred_from).to eq('app')
    #       end
    #     end
    #   end
  
    #   context 'after_save'  do
    #     context '#make_a_copy_to_target_ngo'  do
    #       let!(:family_2){ create(:family, :active) }
    #       let!(:referral_2){ create(:family_referral, referred_from: 'app', referred_to: 'app', family: family_2, slug: "dwp-12") }
  
    #       it 'in app NGO' do
    #         expect(FamilyReferral.count).to eq(1)
    #         expect(FamilyReferral.first.slug).to eq(referral_2.slug)
    #         expect(FamilyReferral.first.name_of_family).to eq(referral_2.name_of_family)
    #         expect(FamilyReferral.first.referred_from).to eq(referral_2.referred_from)
    #         expect(FamilyReferral.first.referred_to).to eq(referral_2.referred_to)
    #         expect(FamilyReferral.first.name_of_referee).to eq(referral_2.name_of_referee)
    #         expect(FamilyReferral.first.referral_phone).to eq(referral_2.referral_phone)
    #         expect(FamilyReferral.first.referee_id).to eq(referral_2.referee_id)
    #         expect(FamilyReferral.first.referral_reason).to eq(referral_2.referral_reason)
    #         expect(FamilyReferral.first.date_of_referral).to eq(referral_2.date_of_referral)
    #         expect(FamilyReferral.first.saved).to eq(referral_2.saved)
    #         expect(FamilyReferral.first.consent_form.present?).to be_truthy
    #         expect(File.basename(FamilyReferral.first.consent_form.first.path)).to eq(File.basename(referral_2.consent_form.first.path))
    #       end
    #     end
    #   end
  
    #   context 'after_create' do
    #     context '#email_referrral_client' do
    #       let!(:user){ create(:user, :admin) }
    #       before do
    #         FactoryBot.create(:user, :admin)
    #         Organization.switch_to 'app'
    #       end
    #       subject(:family_referral_email_notification) { ActionMailer::Base.deliveries }
    #       it 'notify target NGO of new referral' do
    #         expect(EmailFamilyReferralWorker.jobs.size).to eq(0)
    #         expect(EmailFamilyReferralWorker).to be_processed_in 'send_email'
    #       end
    #     end
    #   end
    # end
  
    # describe FamilyReferral, 'scopes'  do
    #   let!(:referral_1){ create(:family_referral, referred_from: 'Organization Testing', referred_to: 'app') }
    #   let!(:referral_2){ create(:family_referral, referred_from: 'Organization Testing', referred_to: 'app', saved: true) }
    #   let!(:referral_3){ create(:family_referral, referred_from: 'Organization Testing', referred_to: 'app', saved: true) }
    #   let!(:referral_4){ create(:family_referral, referred_from: 'Organization Testing', referred_to: 'app') }
  
    #   context '.received' do
    #     it 'not return external referral' do
    #       expect(FamilyReferral.received.ids).to include(referral_3.id, referral_4.id)
    #       expect(FamilyReferral.received.ids).to include(referral_1.id, referral_2.id)
    #     end
    #   end
  
    #   context '.unsaved' do
    #     it 'returns external referral which has not been saved by target NGO' do
    #       expect(FamilyReferral.unsaved.ids).to include(referral_1.id)
    #       expect(FamilyReferral.unsaved.ids).not_to include(referral_2.id)
    #     end
    #   end
  
    #   context '.saved' do
    #     it 'returns external referral which has already been saved by target NGO' do
    #       expect(FamilyReferral.saved.ids).to include(referral_2.id)
    #       expect(FamilyReferral.saved.ids).not_to include(referral_1.id)
    #     end
    #   end
  
    #   context '.received_and_saved' do
    #     it 'returns referrals which are received and saved' do
    #       expect(FamilyReferral.received_and_saved.ids).to include(referral_3.id)
    #       expect(FamilyReferral.received_and_saved.ids).not_to include(referral_1.id)
    #     end
    #   end
  
    #   context '.most_recents' do
    #     it 'returns referrals in descending order' do
    #       expect(FamilyReferral.most_recents.ids).to match_array([referral_4.id, referral_3.id, referral_2.id, referral_1.id])
    #     end
    #   end
  
    #   context '.delivered' do
    #     it 'returns external referrals' do
    #       expect(FamilyReferral&.delivered&.ids).to match_array([])
    #       expect(FamilyReferral&.delivered&.ids).not_to include(nil)
    #     end
    #   end
    # end
  
    # describe FamilyReferral, 'methods' do
    #   let!(:referral_1){ create(:family_referral, referred_from: 'app', referred_to: 'app') }
  
    #   context '#making_referral?' do
    #     it 'returns true/false whether or not the referral is made by the current organization' do
    #       expect(referral_1.making_referral?).to be_truthy
    #     end
    #   end
  
    #   context '#non_oscar_ngo?' do
    #     it 'returns true/false whether target NGO is not using OSCaR' do
    #       expect(referral_1.non_oscar_ngo?).to be_falsey
    #     end
    #   end
  
    #   context '#referred_to_ngo' do
    #     it 'returns full name of target NGo' do
    #       expect(referral_1.referred_to_ngo).to eq('Organization Testing')
    #     end
    #   end
  
    #   context '#referred_from_ngo' do
    #     it 'returns full name of referring NGO' do
    #       expect(referral_1.referred_from_ngo).to eq('Organization Testing')
    #     end
    #   end
    # end
  end
  