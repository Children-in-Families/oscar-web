# FactoryGirl.define do
#   factory :progress_note do
#     date FFaker::Time.date
#     other_location FFaker::Address.city
#     response FFaker::Lorem.paragraph
#     additional_note FFaker::Lorem.paragraph
#
#     association :client, factory: :client
#     association :progress_note_type, factory: :progress_note_type
#     association :location, factory: :location
#     association :material, factory: :material
#     association :user, factory: :user
#   end
# end
