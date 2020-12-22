class ChangePreferredLanguageDefaultValue < ActiveRecord::Migration[5.2]
  def up
    change_column :clients, :preferred_language, :string, default: 'English'
  end

  def down
    change_column :clients, :preferred_language, :string
  end
end
