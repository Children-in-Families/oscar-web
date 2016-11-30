class CreateClientQuantitativeCases < ActiveRecord::Migration
  def change
    create_table :client_quantitative_cases do |t|
      t.references :quantitative_case
      t.references :client

      t.timestamps
    end
  end
end
