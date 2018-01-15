class ChangeFieldDistrictToArchiveDistrictToClient < ActiveRecord::Migration
  def change
    rename_column :clients, :district, :archive_district
  end
end
