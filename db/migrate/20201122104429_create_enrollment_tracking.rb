class CreateEnrollmentTracking < ActiveRecord::Migration
  def change
    create_table :enrollment_trackings do |t|
      t.references :enrollment, index: true, foreign_key: true
      t.references :tracking, index: true, foreign_key: true
      t.jsonb :properties, default: {}

      t.timestamps null: false
    end
  end
end
