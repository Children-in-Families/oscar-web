class AddAssessmentsCountToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :assessments_count, :integer, default: 0, null: false
    add_index :families, :assessments_count
  end
end
