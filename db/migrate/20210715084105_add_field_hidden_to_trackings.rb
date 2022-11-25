class AddFieldHiddenToTrackings < ActiveRecord::Migration[5.2]
  def change
    add_column :trackings, :hidden, :boolean, default: false
  end
end
