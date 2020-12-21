class CreateCaseContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :case_contracts do |t|
      t.date :signed_on
      t.references :case, index: true, foreign_key: true

      t.timestamps
    end
  end
end
