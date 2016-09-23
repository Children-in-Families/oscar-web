class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.integer :from_age
      t.integer :to_age

      t.timestamps null: false
    end
  end
end
