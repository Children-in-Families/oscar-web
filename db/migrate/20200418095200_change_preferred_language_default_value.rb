class ChangePreferredLanguageDefaultValue < ActiveRecord::Migration
  def up
    change_column :clients, :preferred_language, :string, default: 'English'
  end

  def down
    change_column :clients, :preferred_language, :string
  end
end
