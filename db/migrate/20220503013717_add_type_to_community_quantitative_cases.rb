class AddTypeToCommunityQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_column :community_quantitative_cases, :type, :string, default: 'CommunityQuantitativeCase'
    add_column :community_quantitative_cases, :content, :text
    add_column :community_quantitative_cases, :quantitative_type_id, :integer

    add_index :community_quantitative_cases, :quantitative_type_id
    add_index :community_quantitative_cases, :type
  end
end
