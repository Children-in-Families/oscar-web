class IndexForeignKeysInQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_index :quantitative_cases, :quantitative_type_id
  end
end
