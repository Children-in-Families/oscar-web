class AddDeletedAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :deleted_at, :datetime unless column_exists?(:clients, :deleted_at)
    add_index :clients, :deleted_at unless index_exists?(:clients, :deleted_at)
  end
end
