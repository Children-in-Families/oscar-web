class AddDocumentsToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :documents, :string, default: [], array: true
  end
end
