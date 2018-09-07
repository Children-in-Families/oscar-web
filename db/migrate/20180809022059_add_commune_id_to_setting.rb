class AddCommuneIdToSetting < ActiveRecord::Migration
  def change
    add_reference :settings, :commune, index: true, foreign_key: true
  end
end
