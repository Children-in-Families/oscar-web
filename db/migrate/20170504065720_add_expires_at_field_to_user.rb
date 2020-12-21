class AddExpiresAtFieldToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :expires_at, :datetime
  end
end
