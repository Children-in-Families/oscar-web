class DropThreddedMessageboardUsersTable < ActiveRecord::Migration
  def up
    drop_table :thredded_messageboard_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
