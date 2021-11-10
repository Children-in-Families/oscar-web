class IndexForeignKeysInClientsQuantitativeCases < ActiveRecord::Migration
  def change
    add_index :clients_quantitative_cases, :client_id
    add_index :clients_quantitative_cases, :quantitative_case_id
  end
end
