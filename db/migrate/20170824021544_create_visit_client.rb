class CreateVisitClient < ActiveRecord::Migration
  def change
    create_table :visit_clients do |t|
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
