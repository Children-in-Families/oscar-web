class AddFieldToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :google_event_id, :string
  end
end
