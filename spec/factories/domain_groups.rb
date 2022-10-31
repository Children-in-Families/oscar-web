FactoryBot.define do
  factory :domain_group do
    sequence(:name)  { |n| "#{n}-#{FFaker::Name.name}" }

    transient do
      aht { nil }
    end

    after :create do |domain_group, options|
      domain_identies = [['1A', 'Food Security'], ['1B', 'Nutrition and Growth']]
      dimension_identies = [['3a', "(Work skills and education)"], ['2a', "(Physical health)"]]
      if options.aht
        dimension_identies.each do |domain_name, identity|
          create(:domain, name: domain_name, identity: identity, domain_group: domain_group)
        end
      elsif options.aht == false
        domain_identies.each do |domain_name, identity|
          create(:domain, name: domain_name, identity: identity, domain_group: domain_group)
        end
      end
    end
  end
end
