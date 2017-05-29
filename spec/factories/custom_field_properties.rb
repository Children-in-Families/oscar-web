FactoryGirl.define do
  factory :custom_field_property do
    association :custom_formable, factory: :client
    association :custom_field
    custom_formable_type 'Client'
    properties { { "Text Field"=> FFaker::Name.name }.to_json }
    attachments Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/file.docx')))
  end
end
