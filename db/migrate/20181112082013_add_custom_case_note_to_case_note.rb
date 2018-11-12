class AddCustomCaseNoteToCaseNote < ActiveRecord::Migration
  def change
    add_column :case_notes, :custom_case_note, :boolean, default: false
  end
end
