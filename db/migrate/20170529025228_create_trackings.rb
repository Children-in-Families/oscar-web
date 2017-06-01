class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.jsonb :properties
      t.references :client_enrollment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
