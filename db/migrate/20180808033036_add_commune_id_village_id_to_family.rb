class AddCommuneIdVillageIdToFamily < ActiveRecord::Migration[5.2]
  def change
    add_reference :families, :commune, index: true, foreign_key: true
    add_reference :families, :village, index: true, foreign_key: true
  end
end
