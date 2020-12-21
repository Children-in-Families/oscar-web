class CreateCaseClosures < ActiveRecord::Migration[5.2]
  def change
    create_table :case_closures do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
