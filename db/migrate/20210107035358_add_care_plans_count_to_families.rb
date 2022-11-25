class AddCarePlansCountToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :care_plans_count, :integer, default: 0, null: false
    add_index :families, :care_plans_count
  end
end
