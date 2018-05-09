class RenameOrganizationTypeToArchiveOrganizationType < ActiveRecord::Migration
  def change
    rename_column :partners, :organization_type, :archive_organization_type
  end
end
