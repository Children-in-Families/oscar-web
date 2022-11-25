class AddDuplicateCheckerToSharedClient < ActiveRecord::Migration[5.2]
  def change
    add_column :shared_clients, :duplicate_checker, :string
  end
end
