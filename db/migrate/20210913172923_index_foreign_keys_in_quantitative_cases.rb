class IndexForeignKeysInQuantitativeCases < ActiveRecord::Migration
  def change
    add_index :quantitative_cases, :quantitative_type_id
  end
end
