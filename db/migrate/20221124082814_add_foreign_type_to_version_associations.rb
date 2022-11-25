# This migration and AddTransactionIdColumnToVersions provide the necessary
# schema for tracking associations.
class AddForeignTypeToVersionAssociations < ActiveRecord::Migration[5.2]
  def self.up
    add_column :version_associations, :foreign_type, :string, index: true
    remove_index :version_associations,
      name: "index_version_associations_on_foreign_key"
    add_index :version_associations,
      %i(foreign_key_name foreign_key_id foreign_type),
      name: "index_version_associations_on_foreign_key"
  end

  def self.down
    remove_index :version_associations,
      name: "index_version_associations_on_foreign_key"
    remove_column :version_associations, :foreign_type
    add_index :version_associations,
      %i(foreign_key_name foreign_key_id),
      name: "index_version_associations_on_foreign_key"
  end
end
