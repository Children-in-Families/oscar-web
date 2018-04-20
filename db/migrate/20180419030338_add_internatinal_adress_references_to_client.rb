class AddInternatinalAdressReferencesToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :subdistrict, index: true, foreign_key: true
    add_reference :clients, :township, index: true, foreign_key: true
    add_reference :clients, :state, index: true, foreign_key: true
  end
end
