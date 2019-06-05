class AddIndexToDuplicateChecker < ActiveRecord::Migration
  def change
    add_index :shared_clients, :duplicate_checker
  end
end
