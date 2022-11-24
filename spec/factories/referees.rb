FactoryBot.define do
  factory :referee do
    name { "MyString" }
    address_type { "MyString" }
    current_address { "MyString" }
    email { "MyString" }
    gender { "MyString" }
    house_number { "MyString" }
    outside_address { "MyString" }
    street_number { "MyString" }
    province nil
    district nil
    commune nil
    village nil
  end
end
