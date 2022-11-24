FactoryBot.define do
  factory :community do
    name { FFaker::Name.name }
    status { 'accepted' }
    initial_referral_date { FFaker::Time.date }
    association :received_by, factory: :user
    before(:create) do |community|
      community.case_workers << FactoryBot.create(:user)
    end
  end
end
