class AddFieldToReferees < ActiveRecord::Migration
  def change
    add_column :referees, :locality, :string
  end
end
