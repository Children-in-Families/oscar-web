class IndexForeignKeysInClientsQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    add_index :clients_quantitative_cases, :client_id unless index_exists? :clients_quantitative_cases, :client_id
    add_index :clients_quantitative_cases, :quantitative_case_id unless index_exists? :clients_quantitative_cases, :quantitative_case_id
  end
end
