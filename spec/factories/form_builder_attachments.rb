FactoryBot.define do
  factory :form_builder_attachment do
    name { "MyString" }
    file { "" }
    form_buildable_type { "MyString" }
    form_buildable_id { 1 }
  end
end
