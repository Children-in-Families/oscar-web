class CreateCaseClosures < ActiveRecord::Migration
  def change
    create_table :case_closures do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
