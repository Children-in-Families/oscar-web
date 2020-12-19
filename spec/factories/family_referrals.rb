include ActionDispatch::TestProcess
include Rack::Test

FactoryGirl.define do
  factory :family_referral do
    slug "MyString"
    date_of_referral Date.today
    referred_to "mho"
    referred_from "Organization Testing"
    referral_reason FFaker::Lorem.paragraph
    name_of_referee FFaker::Name.name
    referral_phone FFaker::PhoneNumber.phone_number
    name_of_family FFaker::Name.name
    referee_id 1
    saved false
    association :family, factory: :family
    consent_form { [UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx')))] }

    after(:build) do |referral|
      family_referral.class.skip_callback(:save, :after, :make_a_copy_to_target_ngo)
    end

    after(:build) do |r|
      r.slug = r.family.slug
      r.save
    end
  end
end
