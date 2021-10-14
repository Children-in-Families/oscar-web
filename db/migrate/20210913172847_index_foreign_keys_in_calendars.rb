class IndexForeignKeysInCalendars < ActiveRecord::Migration
  def change
    add_index :calendars, :google_event_id
  end
end
