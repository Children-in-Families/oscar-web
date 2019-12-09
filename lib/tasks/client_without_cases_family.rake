namespace :client_without_cases_family do
  desc "Attach family to client whos id was in family's children field"
  task restore: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share' || short_name != 'cif'
      Organization.switch_to short_name
      family_client_ids = Family.where("array_upper(children, 1) is not null").pluck(:children).flatten
      Client.where(id: family_client_ids, current_family_id: nil).each do |client|
        family = Family.where('children && ARRAY[?]', client.id).last
        client.current_family_id = family.id
        client.save(validate: false)
        puts "#{short_name}: #{client.slug}"
      end
    end
  end
end
