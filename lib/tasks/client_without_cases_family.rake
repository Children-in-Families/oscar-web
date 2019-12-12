namespace :client_without_cases_family do
  desc "Attach family to client whos id was in family's children field"
  task restore: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share' || short_name != 'cif'
      Organization.switch_to short_name

      family_ids = Family.where("array_upper(children, 1) is not null").ids
      PaperTrail::Version.where(item_type: 'Family', event: 'update', item_id: family_ids).where('object_changes iLIKE ?', "%\nchildren%").order(:created_at).group_by(&:item_id).each do |family_id, versions|
        version = versions.reject{|version| version.whodunnit == 'deployer@rotati' }.last
        if version.present?
          client_ids = version.changeset['children'].last
          family = Family.find(family_id)
          family.update(children: client_ids)
          Client.where(id: client_ids).update_all(current_family_id: family_id)
          puts "#{short_name}: #{client_ids}"
        end
      end

    end
  end
end
