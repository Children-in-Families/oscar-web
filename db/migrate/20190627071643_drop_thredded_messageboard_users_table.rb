class DropThreddedMessageboardUsersTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :thredded_messageboard_users if table_exists? :thredded_messageboard_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
