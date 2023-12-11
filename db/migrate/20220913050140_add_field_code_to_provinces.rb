class AddFieldCodeToProvinces < ActiveRecord::Migration
  def change
    add_column :provinces, :code, :string, limit: 2
  end
end
