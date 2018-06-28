namespace :update_family_types do
  desc "Update family types and mark all families with Active status"
  task start: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Family.all.each do |family|
        family_type = family.family_type
        new_type =  case family_type
                    when 'emergency' then 'Short Term / Emergency Foster Care'
                    when 'kinship' then 'Extended Family / Kinship Care'
                    when 'foster', 'inactive' then 'Long Term Foster Care'
                    when 'birth_family' then 'Birth Family (Both Parents)'
                    else family_type
                    end
        family.family_type = new_type
        family.status = 'Active'
        family.save
      end
    end
  end
end
