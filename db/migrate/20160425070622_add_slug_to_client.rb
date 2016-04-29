class AddSlugToClient < ActiveRecord::Migration
  def change
    add_column :clients, :slug, :string
    add_index :clients, :slug, unique: true
  end
end
