class AddCodeAndTimestampToDistrict < ActiveRecord::Migration
  def change
    add_column :districts, :code, :string, default: ''
    add_timestamps :districts
  end
end
