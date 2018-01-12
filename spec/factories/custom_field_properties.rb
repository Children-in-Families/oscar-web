FactoryGirl.define do
  factory :custom_field_property do
    association :custom_field, factory: :custom_field
    properties { { "Hello World"=> FFaker::Name.name }.to_json }
    attachments Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx')))
    custom_formable_type 'Client'
    association :custom_formable, factory: :client

    trait :client_custom_field_property do
      custom_formable_type 'Client'
      association :custom_formable, factory: :client
    end

    trait :partner_custom_field_property do
      association :custom_formable, factory: :partner
      custom_formable_type 'Partner'
    end

    trait :family_custom_field_property do
      association :custom_formable, factory: :family
      custom_formable_type 'Family'
    end
  end
end
