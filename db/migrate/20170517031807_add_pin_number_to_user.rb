class AddPinNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :pin_number, :integer
  end
end
