class CreateFamilyPlans < ActiveRecord::Migration
  def change
    create_table :family_plans do |t|
      t.string :name, default: ''

      t.timestamps null: false
    end
  end
end
