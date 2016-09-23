class AddOrderOptionToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :order_option, :integer, default: 0
  end
end
