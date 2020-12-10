class AddFamilyQuantitativeCases < ActiveRecord::Migration
  def change
    create_table :family_quantitative_cases do |t|
      t.references :quantitative_case, foreign_key: true
      t.references :family, foreign_key: true

      t.timestamps
    end
  end
end
