class AddFieldProgramStreamIdToTracking < ActiveRecord::Migration[5.2]
  def change
    add_column :trackings, :program_stream_id, :integer
  end
end
