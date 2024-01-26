class CreateRelaseNotes < ActiveRecord::Migration
  def change
    create_table :relase_notes do |t|
      t.text :content, null: false
      t.integer :created_by_id, index: true
      t.integer :published_by_id, index: true
      t.boolean :published, default: false
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
