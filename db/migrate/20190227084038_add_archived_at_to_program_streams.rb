class AddArchivedAtToProgramStreams < ActiveRecord::Migration[5.2]
  def change
    add_column :program_streams, :archived_at, :datetime
    add_index :program_streams, :archived_at
  end
end
