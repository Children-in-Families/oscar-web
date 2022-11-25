class IndexForeignKeysInFamilyQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_index :family_quantitative_cases, :family_id
    add_index :family_quantitative_cases, :quantitative_case_id
  end
end
