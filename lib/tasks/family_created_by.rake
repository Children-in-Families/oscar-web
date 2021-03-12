namespace :family_created_by do
  desc "Reattach family. Bug remove user_id from family after attach family to a client"
  task reattach: :environment do
    Organization.visible.pluck(:short_name).each do |short_name|
      puts "Start schema: #{short_name} ..."
      Apartment::Tenant.switch short_name
      Family.where(user_id: nil).each do |family|
        version = PaperTrail::Version.where(item_type: 'Family', event: 'create').find_by(item_id: family.id)
        if version
          family.update_column(:user_id, version.whodunnit) if User.exists?(version.whodunnit)
        end
      end
    end
  end
end

