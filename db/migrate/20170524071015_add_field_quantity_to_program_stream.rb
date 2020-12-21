class AddFieldQuantityToProgramStream < ActiveRecord::Migration[5.2]
  def change
    add_column :program_streams, :quantity, :integer
  end
end
