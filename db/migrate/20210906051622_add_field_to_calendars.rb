class AddFieldToCalendars < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :google_event_id, :string
  end
end
