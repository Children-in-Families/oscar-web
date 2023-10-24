class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notifiable, index: true, polymorphic: true
      t.string :key, null: false
      t.datetime :seen_at
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
