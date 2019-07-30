class AddDuplicateCheckerToSharedClient < ActiveRecord::Migration
  def change
    add_column :shared_clients, :duplicate_checker, :string
  end
end
