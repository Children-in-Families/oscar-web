class AddVisibleOnToQuantitativeTypes < ActiveRecord::Migration
  def change
    add_column :quantitative_types, :visible_on, :string, default: %w(client).to_yaml
  end
end
