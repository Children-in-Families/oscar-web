class ChangeFieldDistrictToArchiveDistrictToClient < ActiveRecord::Migration[5.2]
  def change
    rename_column :clients, :district, :archive_district
  end
end
