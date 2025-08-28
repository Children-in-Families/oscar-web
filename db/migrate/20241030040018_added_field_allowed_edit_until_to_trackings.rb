class AddedFieldAllowedEditUntilToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :allowed_edit_until, :string
  end
end
