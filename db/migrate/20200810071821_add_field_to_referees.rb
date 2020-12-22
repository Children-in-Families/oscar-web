class AddFieldToReferees < ActiveRecord::Migration[5.2]
  def change
    add_column :referees, :locality, :string
  end
end
