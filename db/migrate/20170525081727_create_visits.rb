class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
