namespace :update_user_permission_set do
  desc 'Update user permission set Able/EC/FC/KC Manager to only manager'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      users = User.where("roles like ?", "%manager%")
      users.each do |user|
        user.roles = 'manager'
        user.save(validate: false)
      end
    end
  end
end
