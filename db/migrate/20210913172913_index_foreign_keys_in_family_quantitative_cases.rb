class IndexForeignKeysInFamilyQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_index :family_quantitative_cases, :family_id unless index_exists? :family_quantitative_cases, :family_id
    add_index :family_quantitative_cases, :quantitative_case_id unless index_exists? :family_quantitative_cases, :quantitative_case_id
  end
end
