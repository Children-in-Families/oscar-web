class IndexForeignKeysInCommunityQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_index :community_quantitative_cases, :community_id
    add_index :community_quantitative_cases, :quantitative_case_id
  end
end
