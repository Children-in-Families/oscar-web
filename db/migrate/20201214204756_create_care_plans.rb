class CreateCarePlans < ActiveRecord::Migration
  def change
    create_table :care_plans do |t|
      t.references :assessment, index: true, foreign_key: true
      t.references :client, index: true, foreign_key: true

      t.timestamps
    end
  end
end
