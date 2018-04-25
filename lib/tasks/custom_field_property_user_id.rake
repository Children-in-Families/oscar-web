namespace :custom_field_property_user_id do
  desc 'Update custom field property user_id'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      ids = CustomFieldProperty.where(user_id: nil).ids
      versions = PaperTrail::Version.where(item_type: 'CustomFieldProperty', event: 'create', item_id: ids)
      versions.each do |version|
        user = User.find_by(id: version.whodunnit)
        next if user.nil? || version.item.nil?

        version.item.update_columns(user_id: user.id)
      end
    end
  end
end
