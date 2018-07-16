class CreateGovernmentFormChildrenPlans < ActiveRecord::Migration
  def change
    create_table :government_form_children_plans do |t|
      t.string :goal
      t.string :action
      t.string :who
      t.string :when
      t.references :government_form, index: true, foreign_key: true
      t.references :children_plan, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
