class AddSlugToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :slug, :string, default: '', unique: true
  end
end
