class AddCustomCaseNoteToCaseNote < ActiveRecord::Migration
  def up
    add_column :case_notes, :custom, :boolean, default: false
    CaseNote.update_all(custom: true) if ['mho', 'fsc', 'tlc'].include?(Organization.current.try(:short_name))
  end

  def down
    remove_column :case_notes, :custom, :boolean, default: false
  end
end
