class AddVisibleOnToQuantitativeTypes < ActiveRecord::Migration
  def change
    add_column :quantitative_types, :visible_on, :string
  end
end
