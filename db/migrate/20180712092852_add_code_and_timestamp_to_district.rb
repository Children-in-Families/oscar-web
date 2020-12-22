class AddCodeAndTimestampToDistrict < ActiveRecord::Migration[5.2]
  def change
    add_column :districts, :code, :string, default: ''
    add_timestamps :districts
  end
end
