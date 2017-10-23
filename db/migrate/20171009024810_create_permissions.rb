class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :user, index: true
      t.boolean :case_notes_readable, deafult: false
      t.boolean :case_notes_editable, deafult: false
      t.boolean :assessments_editable, deafult: false
      t.boolean :assessments_readable, deafult: false

      t.timestamps null: false
    end
  end
end
