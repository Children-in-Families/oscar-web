class AddMultipleToQuantitativeTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :quantitative_types, :multiple, :boolean, default: true
  end
end
