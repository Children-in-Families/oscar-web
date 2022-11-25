class AddTypeToFamilyQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_column :family_quantitative_cases, :type, :string, default: 'FamilyQuantitativeCase'
    add_column :family_quantitative_cases, :content, :text
    add_column :family_quantitative_cases, :quantitative_type_id, :integer

    add_index :family_quantitative_cases, :quantitative_type_id
    add_index :family_quantitative_cases, :type
  end
end
