class AddFieldHiddenToCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :hidden, :boolean, default: false
  end
end
