class AddNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, default: ''

    unprocessable_users = []

    puts '========== Processing =========='

    User.find_each do |user|
      name = "#{user.first_name} #{user.last_name}"
      begin
        user.update_attributes!(name: name)
      rescue
        unprocessable_users << user.id
        puts "===== error user id #{user.id} ====="
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_users} >> error.txt" if unprocessable_users.present?
  end
end
