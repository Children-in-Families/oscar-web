class AddOrganizationTypeRefToPartners < ActiveRecord::Migration
  def change
    add_reference :partners, :organization_type, index: true, foreign_key: true
  end
end
