class IndexForeignKeysInCalendars < ActiveRecord::Migration[5.2]
  def change
    add_index :calendars, :google_event_id
  end
end
