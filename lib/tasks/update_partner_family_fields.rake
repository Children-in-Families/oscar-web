namespace :trim_field_name do
  desc 'Update Name'
  task family: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Family.all.each do |family|
        family.update(name: family.name.squish)
      end
    end
  end

  task partner: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Partner.all.each do |partner|
        partner.update(contact_person_name: partner.contact_person_name.squish)
      end
    end
  end

end
