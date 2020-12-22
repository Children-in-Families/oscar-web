class AddOrganizationTypeRefToPartners < ActiveRecord::Migration[5.2]
  def change
    add_reference :partners, :organization_type, index: true, foreign_key: true
  end
end
