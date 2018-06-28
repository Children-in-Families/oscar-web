include ActionDispatch::TestProcess
include Rack::Test

FactoryGirl.define do
  factory :referral do
    slug "MyString"
    date_of_referral Date.today
    referred_to "mtp"
    referred_from "Organization Testing"
    referral_reason FFaker::Lorem.paragraph
    name_of_referee FFaker::Name.name
    referral_phone FFaker::PhoneNumber.phone_number
    client_name FFaker::Name.name
    referee_id 1
    saved false
    association :client, factory: :client
    consent_form { [UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx')))] }
  end
end
