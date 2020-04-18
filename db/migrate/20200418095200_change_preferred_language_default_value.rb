class ChangePreferredLanguageDefaultValue < ActiveRecord::Migration
  def change
    change_column :clients, :preferred_language, :string, default: 'English'
  end
end
