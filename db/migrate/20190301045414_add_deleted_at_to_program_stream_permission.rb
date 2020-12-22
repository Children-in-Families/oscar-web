class AddDeletedAtToProgramStreamPermission < ActiveRecord::Migration[5.2]
  def change
    add_column :program_stream_permissions, :deleted_at, :datetime
    add_index :program_stream_permissions, :deleted_at
  end
end
