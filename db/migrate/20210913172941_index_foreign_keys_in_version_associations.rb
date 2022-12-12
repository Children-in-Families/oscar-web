class IndexForeignKeysInVersionAssociations < ActiveRecord::Migration[5.2]
  def change
    add_index :version_associations, :foreign_key_id unless index_exists? :version_associations, :foreign_key_id
  end
end
