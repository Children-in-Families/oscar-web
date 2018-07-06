class CreateGovernmentFormProblem < ActiveRecord::Migration
  def change
    create_table :government_form_problems do |t|
      t.references :problem, index: true, foreign_key: true
      t.references :government_form, index: true, foreign_key: true

      t.timestamps
    end
  end
end
