class MoveManagerIdToManagerIds < ActiveRecord::Migration[5.2]
  def up
    unprocessable_users = []

    puts '==========Processing=========='

    User.all.each do |user|
      if user.manager_id.present?
        begin
          user.manager_ids << user.manager_id
          user.save
        rescue
          unprocessable_users << user.id
        end
      end
    end
    puts '==========Done=========='
    system "echo #{unprocessable_users} >> error.txt" if unprocessable_users.present?
  end

  def down
    User.all.each do |user|
      user.manager_ids = []
      user.save
    end
  end
end
