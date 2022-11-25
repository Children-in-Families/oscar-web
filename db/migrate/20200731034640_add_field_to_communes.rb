class AddFieldToCommunes < ActiveRecord::Migration[5.2]
  def change
    add_column :communes, :district_type, :string
  end
end
