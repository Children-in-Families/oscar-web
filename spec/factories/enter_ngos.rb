FactoryGirl.define do
  factory :enter_ngo do
    accepted_date FFaker::Time.date
    association :client, factory: :client

    # trait :with_users do |e|
    #   e.users << FactoryGirl.create(:user)
    # end
  end
end
