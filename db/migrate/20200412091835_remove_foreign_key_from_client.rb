class RemoveForeignKeyFromClient < ActiveRecord::Migration
  def change
    remove_foreign_key :clients, column: :global_id
  end
end
