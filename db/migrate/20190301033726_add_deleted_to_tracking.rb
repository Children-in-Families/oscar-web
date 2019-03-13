class AddDeletedToTracking < ActiveRecord::Migration
  def change
    add_column :trackings, :deleted_at, :datetime
    add_index :trackings, :deleted_at
  end
end
