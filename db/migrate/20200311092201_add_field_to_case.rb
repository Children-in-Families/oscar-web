class AddFieldToCase < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :deleted_at, :datetime
    add_index :cases, :deleted_at
  end
end
