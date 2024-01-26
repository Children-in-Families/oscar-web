include ActionDispatch::TestProcess
include Rack::Test

FactoryGirl.define do
  factory :referral do
    slug "MyString"
    date_of_referral Date.today
    referred_to "mtp"
    referred_from "Organization Testing"
    referral_reason FFaker::Lorem.paragraph
    referral_status "Accepted"
    name_of_referee FFaker::Name.name
    referral_phone FFaker::PhoneNumber.phone_number
    client_name FFaker::Name.name
    referee_id 1
    saved false
    association :client, factory: :client
    consent_form { [UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx')))] }

    after(:build) do |referral|
      referral.class.skip_callback(:save, :after, :create_referral_history)
      referral.class.skip_callback(:save, :after, :make_a_copy_to_target_ngo)
    end

    after(:build) do |r|
      r.slug = r.client.slug
      r.client_global_id = r.client.global_id
      r.save
    end

    trait :client_with_history do
      after(:build) do |referral|
        referral.class.set_callback(:save, :after, :create_referral_history)
      end
    end


  end
end
