class FixApartmentContraintUserOrganization < ActiveRecord::Migration[5.2]

  def self.up
    remove_foreign_key :users, column: :organization_id
    add_foreign_key :users, "public.organizations", column: :organization_id
  end

  def self.down
    remove_foreign_key :users, column: :organization_id
    add_foreign_key :users, :organizations, column: :organization_id
  end
end
