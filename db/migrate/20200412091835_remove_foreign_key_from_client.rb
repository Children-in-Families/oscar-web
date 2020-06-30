class RemoveForeignKeyFromClient < ActiveRecord::Migration
  def change
    remove_foreign_key :clients, column: :global_id if foreign_keys(:clients).map(&:column).include?("global_id")
  end
end
