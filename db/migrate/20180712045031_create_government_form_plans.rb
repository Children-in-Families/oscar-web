class CreateGovernmentFormPlans < ActiveRecord::Migration
  def change
    create_table :government_form_plans do |t|
      t.string :goal
      t.string :action
      t.string :result
      t.references :government_form, index: true, foreign_key: true
      t.references :plan, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
