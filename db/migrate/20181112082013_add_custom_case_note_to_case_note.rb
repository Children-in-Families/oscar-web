class AddCustomCaseNoteToCaseNote < ActiveRecord::Migration
  def change
    add_column :case_notes, :custom, :boolean, default: false
  end
end
