class MoveDataManagerIdToManagerIds < ActiveRecord::Migration
  def up
    unprocessable_users = []

    puts '==========Processing=========='

    User.all.each do |user|
      if user.manager_id.present?
        begin
          user.manager_ids << user.manager_id
          user.save
        rescue
          unprocessable_users << client.id
        end
      end
    end
    puts '==========Done=========='

    system "echo #{unprocessable_users} >> error.txt" if unprocessable_users.present?
  end
end
