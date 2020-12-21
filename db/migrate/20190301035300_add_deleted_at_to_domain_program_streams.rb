class AddDeletedAtToDomainProgramStreams < ActiveRecord::Migration[5.2]
  def change
    add_column :domain_program_streams, :deleted_at, :datetime
    add_index :domain_program_streams, :deleted_at
  end
end
