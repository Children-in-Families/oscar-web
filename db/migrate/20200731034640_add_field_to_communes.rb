class AddFieldToCommunes < ActiveRecord::Migration
  def change
    add_column :communes, :district_type, :string
  end
end
