FactoryBot.define do
  factory :village do
    name_kh { FFaker::Name.name }
    name_en { FFaker::Name.name }
    sequence(:code){|n| Time.now.to_f.to_s.last(4) + n.to_s }
    commune { Commune.first || association(:commune) }
  end
end
