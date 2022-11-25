class AddTypeToClientQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_column :client_quantitative_cases, :type, :string, default: 'ClientQuantitativeCase'
    add_column :client_quantitative_cases, :content, :text
    add_column :client_quantitative_cases, :quantitative_type_id, :integer

    add_index :client_quantitative_cases, :quantitative_type_id
    add_index :client_quantitative_cases, :type
  end
end
