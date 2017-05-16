class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :title
      t.datetime :start_date
      t.datetime :end_date
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
