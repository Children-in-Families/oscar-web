class AddFamilyPreservationToCases < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :family_preservation, :boolean, default: false
  end
end
