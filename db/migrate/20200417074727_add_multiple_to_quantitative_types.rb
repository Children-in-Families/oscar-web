class AddMultipleToQuantitativeTypes < ActiveRecord::Migration
  def change
    add_column :quantitative_types, :multiple, :boolean, default: true
  end
end
