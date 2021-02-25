class AddFieldsToQuantitativeType < ActiveRecord::Migration
  def change
    add_column :quantitative_types, :is_required, :boolean, default: false
  end
end
