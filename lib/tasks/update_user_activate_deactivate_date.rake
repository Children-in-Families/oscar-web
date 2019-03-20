namespace :user_activate_deactivate do
  desc 'update users activated and deactivated date'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      User.all.each do |user|
        was_disabled_at = PaperTrail::Version.where(item_type: 'User', item_id: user.id, event: 'update').where_object(disable: true).last.try(:created_at)
        was_enabled_at  = PaperTrail::Version.where(item_type: 'User', item_id: user.id, event: 'update').where_object(disable: false).where('created_at > ?', was_disabled_at).first.try(:created_at) if was_disabled_at.present?
        if was_disabled_at.present?
          user.update_column('deactivated_at', was_disabled_at)
          if user.disable == false
            user.update_column('activated_at', was_enabled_at)
          end
        end
      end
    end
    puts 'Done!!!'
  end
end
