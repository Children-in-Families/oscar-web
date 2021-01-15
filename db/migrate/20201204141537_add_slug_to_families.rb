class AddSlugToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :slug, :string, default: '', unique: true
  end
end
