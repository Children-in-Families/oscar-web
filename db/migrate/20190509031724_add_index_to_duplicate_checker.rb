class AddIndexToDuplicateChecker < ActiveRecord::Migration[5.2]
  def change
    add_index :shared_clients, :duplicate_checker
  end
end
