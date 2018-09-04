class CreateChildrenPlans < ActiveRecord::Migration
  def change
    create_table :children_plans do |t|
      t.string :name, default: ''

      t.timestamps null: false
    end
  end
end
