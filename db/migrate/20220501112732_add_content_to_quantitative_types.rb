class AddContentToQuantitativeTypes < ActiveRecord::Migration
  def change
    add_column :quantitative_types, :hint, :string
    add_column :quantitative_types, :field_type, :string, default: 'select_option'
  end
end
