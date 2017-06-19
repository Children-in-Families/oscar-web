class AddFieldQuantityToProgramStream < ActiveRecord::Migration
  def change
    add_column :program_streams, :quantity, :integer
  end
end
