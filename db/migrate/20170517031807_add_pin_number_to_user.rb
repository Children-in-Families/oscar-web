class AddPinNumberToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pin_number, :integer
  end
end
