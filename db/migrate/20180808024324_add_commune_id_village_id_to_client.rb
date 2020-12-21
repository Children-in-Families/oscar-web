class AddCommuneIdVillageIdToClient < ActiveRecord::Migration[5.2]
  def change
    add_reference :clients, :commune, index: true, foreign_key: true
    add_reference :clients, :village, index: true, foreign_key: true
  end
end
