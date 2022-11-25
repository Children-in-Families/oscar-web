class AddDistrictIdToClient < ActiveRecord::Migration[5.2]
  def change
    add_reference :clients, :district, index: true, foreign_key: true
  end
end
