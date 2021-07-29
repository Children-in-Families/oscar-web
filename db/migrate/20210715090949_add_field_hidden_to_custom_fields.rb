class AddFieldHiddenToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :hidden, :boolean, default: false
  end
end
