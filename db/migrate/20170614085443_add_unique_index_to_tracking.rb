class AddUniqueIndexToTracking < ActiveRecord::Migration
  def change
    add_index :trackings, [:name, :program_stream_id], unique: true
  end
end
