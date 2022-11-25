class AddLegalDocNewFieldsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :letter_from_immigration_police, :boolean, default: false
    add_column :clients, :letter_from_immigration_police_files, :string, default: [], array: true
  end
end
