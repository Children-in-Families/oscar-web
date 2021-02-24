class AddFieldsToQuantitativeType < ActiveRecord::Migration
  def change
    add_column :quantitative_types, :is_required, :boolean, default: false
    add_column :quantitative_types, :is_multi_select, :boolean, default: false
  end
end
