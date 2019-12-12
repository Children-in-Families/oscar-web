namespace :client_without_cases_family do
  desc "Attach family to client whos id was in family's children field"
  task restore: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      Family.where("array_upper(children, 1) is not null").each do |family|
        versions = family.versions.where('event = ? AND object_changes iLIKE ? AND whodunnit != ?', 'update', "%\nchildren%", 'deployer@rotati')
        # check last change set created by user
        begin
        next if versions.nil? || versions.last.blank?
        changeset = versions.last.changeset
        last_version_children = changeset['children'].last

        rescue Exception => e
        binding.pry

        end
        next if last_version_children.sort == family.children.sort
        binding.pry if versions.present?
      end

      # PaperTrail::Version.where(item_type: 'Family', event: 'update', item_id: family_ids).where('object iLIKE ? AND whodunnit != ?', '%children%', 'deployer@rotati').each do |version|
      # end
      # Client.where(id: family_client_ids, current_family_id: nil).each do |client|
      #   client.current_family_id = client.family.id
      #   client.save(validate: false)
      #   puts "#{short_name}: #{client.slug}"
      # end
    end
  end
end
