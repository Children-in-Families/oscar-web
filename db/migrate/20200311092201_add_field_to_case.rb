class AddFieldToCase < ActiveRecord::Migration
  def change
    add_column :cases, :deleted_at, :datetime
    add_index :cases, :deleted_at
  end
end
