class CreateGovernmentFormProblem < ActiveRecord::Migration[5.2]
  def change
    create_table :government_form_problems do |t|
      t.integer :rank
      t.references :problem, index: true, foreign_key: true
      t.references :government_form, index: true, foreign_key: true

      t.timestamps
    end
  end
end
