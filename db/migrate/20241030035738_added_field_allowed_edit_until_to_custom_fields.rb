class AddedFieldAllowedEditUntilToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :allowed_edit_until, :string
  end
end
