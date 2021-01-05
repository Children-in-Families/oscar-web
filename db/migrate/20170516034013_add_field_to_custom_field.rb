class AddFieldToCustomField < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :fields, :jsonb
  end
end
