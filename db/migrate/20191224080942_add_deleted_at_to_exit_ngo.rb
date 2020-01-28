class AddDeletedAtToExitNgo < ActiveRecord::Migration
  def change
    add_column :exit_ngos, :deleted_at, :datetime
    add_index :exit_ngos, :deleted_at
  end
end
