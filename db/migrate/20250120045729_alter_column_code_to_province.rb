class AlterColumnCodeToProvince < ActiveRecord::Migration
  def change
    change_column(:provinces, :code, :string, limit: 7)
  end
end
