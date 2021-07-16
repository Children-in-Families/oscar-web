class AddFieldHiddenToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :hidden, :boolean, default: false
  end
end
