class ChangeColumnMeetingDateOfCaseNote < ActiveRecord::Migration[5.2]
  def up
    change_column  :case_notes, :meeting_date, :datetime

    minute_added = 0
    values = CaseNote.all.map do |case_note|
      minute_added = 0 if minute_added == 59
      case_note_meeting_date = case_note.meeting_date + (minute_added += 1).minute
      "(#{case_note.id}, '#{case_note_meeting_date.to_s}')"
    end.join(", ")

    if values.present?
      execute <<-SQL.squish
        UPDATE case_notes SET meeting_date = mapping_values.meeting_date::timestamptz FROM (VALUES #{values}) AS mapping_values (case_note_id, meeting_date) WHERE case_notes.id = mapping_values.case_note_id;
      SQL
    end
  end

  def down
    change_column  :case_notes, :meeting_date, :date
  end
end
