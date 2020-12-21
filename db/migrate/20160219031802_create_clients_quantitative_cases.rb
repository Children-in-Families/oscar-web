class CreateClientsQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    create_table :clients_quantitative_cases do |t|

      t.belongs_to :client
      t.belongs_to :quantitative_case

      t.timestamps
    end
  end
end
