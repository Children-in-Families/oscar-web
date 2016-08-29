class AddAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false

    unprocessable_users = []

    puts '========== Processing =========='

    User.find_each do |user|
      begin
        user.update_attributes!(admin: true) if user.admin?
      rescue
        unprocessable_users << user.id
        puts "===== error user id #{user.id} ====="
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_users} >> error.txt" if unprocessable_users.present?
  end
end