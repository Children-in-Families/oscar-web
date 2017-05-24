class AddFieldToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :fields, :jsonb
  end
end
