class AddFieldToFamily < ActiveRecord::Migration
  def change
    add_column :families, :deleted_at, :datetime
    add_index :families, :deleted_at
  end
end
