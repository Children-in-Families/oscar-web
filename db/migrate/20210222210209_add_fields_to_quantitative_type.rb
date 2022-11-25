class AddFieldsToQuantitativeType < ActiveRecord::Migration[5.2]
  def change
    add_column :quantitative_types, :is_required, :boolean, default: false
  end
end
