class IndexForeignKeysInClientQuantitativeCases < ActiveRecord::Migration
  def change
    add_index :client_quantitative_cases, :client_id
    add_index :client_quantitative_cases, :quantitative_case_id
  end
end
