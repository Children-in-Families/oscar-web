class AddTrackingToProgramStream < ActiveRecord::Migration[5.2]
  def change
    add_column :program_streams, :tracking_required, :boolean, default: false
  end
end
