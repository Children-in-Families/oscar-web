class AddCommuneIdVillageIdToFamily < ActiveRecord::Migration
  def change
    add_reference :families, :commune, index: true, foreign_key: true
    add_reference :families, :village, index: true, foreign_key: true
  end
end
