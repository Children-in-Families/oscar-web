class CreateCaseNotes < ActiveRecord::Migration
  def change
    create_table :case_notes do |t|
      t.string     :attendee, default: ''
      t.date       :meeting_date

      t.references :case
      t.references :assessment

      t.timestamps
    end
  end
end
