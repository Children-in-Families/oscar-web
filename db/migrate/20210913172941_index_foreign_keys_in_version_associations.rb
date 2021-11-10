class IndexForeignKeysInVersionAssociations < ActiveRecord::Migration
  def change
    add_index :version_associations, :foreign_key_id
  end
end
