class AddPreferredLanToUsers < ActiveRecord::Migration
  def change
    remove_column :clients, :preferred_language, :string
    add_column :users, :preferred_language, :string, default: :en
  end
end
