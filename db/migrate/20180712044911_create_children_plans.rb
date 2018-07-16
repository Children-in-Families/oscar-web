class CreateChildrenPlans < ActiveRecord::Migration
  def change
    create_table :children_plans do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
