class AddForToAdvancedSearches < ActiveRecord::Migration
  def change
    add_column :advanced_searches, :search_for, :string, default: 'client'
  end
end
