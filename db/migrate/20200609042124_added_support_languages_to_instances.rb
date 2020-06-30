class AddedSupportLanguagesToInstances < ActiveRecord::Migration
  def change
    add_column :organizations, :supported_languages, :string, default: ['km', 'en', 'my'], array: true
  end
end
