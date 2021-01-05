class UpdateVisitorRoleToStrategicOverviewer < ActiveRecord::Migration[5.2]
  def change
    unprocessable_users = []

    puts '==========Processing=========='

    User.find_each do |user|
      begin
        user.update_attributes!(roles: 'strategic overviewer') if user.roles == 'visitor'
      rescue
        unprocessable_users << user.id
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_users} >> error.txt" if unprocessable_users.present?
  end
end
