class AddFieldProgramStreamIdToTracking < ActiveRecord::Migration
  def change
    add_column :trackings, :program_stream_id, :integer
  end
end
