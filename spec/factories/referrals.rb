include ActionDispatch::TestProcess
include Rack::Test

FactoryGirl.define do
  factory :referral do
    slug "MyString"
    date_of_referral "2018-05-24"
    referred_to "mtp"
    referred_from "Organization Testing"
    referral_reason "MyText"
    name_of_referee "MyString"
    referral_phone "MyString"
    client_name "MyString"
    referee_id 1
    saved false
    association :client, factory: :client
    consent_form { UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx'))) }
  end
end
