class CreateFamilyPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :family_plans do |t|
      t.string :name, default: ''

      t.timestamps null: false
    end
  end
end
