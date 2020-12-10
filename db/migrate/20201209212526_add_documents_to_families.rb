class AddDocumentsToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :documents, :string, default: [], array: true
  end
end
