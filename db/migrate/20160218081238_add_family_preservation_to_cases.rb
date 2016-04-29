class AddFamilyPreservationToCases < ActiveRecord::Migration
  def change
    add_column :cases, :family_preservation, :boolean, default: false
  end
end
