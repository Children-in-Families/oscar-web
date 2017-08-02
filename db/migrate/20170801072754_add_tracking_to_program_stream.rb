class AddTrackingToProgramStream < ActiveRecord::Migration
  def change
    add_column :program_streams, :tracking_required, :boolean, default: false
  end
end
