class AddPreferredLanguageToClients < ActiveRecord::Migration
  def change
    add_column :clients, :preferred_language, :string
  end
end
