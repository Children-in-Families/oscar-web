class AddedSupportLanguagesToInstances < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :supported_languages, :string, default: ['km', 'en', 'my'], array: true
  end
end
