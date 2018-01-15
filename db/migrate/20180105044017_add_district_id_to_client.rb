class AddDistrictIdToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :district, index: true, foreign_key: true
  end
end
