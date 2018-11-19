class AddCustomCaseNoteToCaseNote < ActiveRecord::Migration
  def up
    add_column :case_notes, :custom, :boolean, default: false
    Assessment.update_all(default: true) if ['mho', 'fsc', 'tlc'].exclude?(Organization.current.try(:short_name))
  end

  def down
    remove_column :case_notes, :custom, :boolean, default: false
  end
end
