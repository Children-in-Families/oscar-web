class AddTrackingToProgramStream < ActiveRecord::Migration
  def change
    add_column :program_streams, :tracking, :boolean, default: false
  end
end
