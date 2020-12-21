class CreateQuantitativeTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :quantitative_types do |t|
      t.string :name, default: ''
      t.text   :description, default: ''
      t.integer :quantitative_cases_count, default: 0

      t.timestamps
    end
  end
end
