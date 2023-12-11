class AddUsersCountToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :users_count, :integer, default: 0

    current = Apartment::Tenant.current
    puts "Update users count for #{current} - users count: #{User.non_devs.count}}"
    Organization.where(short_name: current).update_all(users_count: User.non_devs.count)
  end
end
