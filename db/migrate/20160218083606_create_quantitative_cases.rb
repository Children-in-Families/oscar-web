class CreateQuantitativeCases < ActiveRecord::Migration[5.2]
  def change
    create_table :quantitative_cases do |t|
      t.string :value, default: ''

      t.references :quantitative_type

      t.timestamps
    end
  end
end
