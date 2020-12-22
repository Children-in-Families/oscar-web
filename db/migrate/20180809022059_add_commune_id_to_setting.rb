class AddCommuneIdToSetting < ActiveRecord::Migration[5.2]
  def change
    add_reference :settings, :commune, index: true, foreign_key: true
  end
end
