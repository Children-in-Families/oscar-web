class AddFieldNoteToCaseNote < ActiveRecord::Migration
  def change
    add_column :case_notes, :note, :text, default: ''
  end
end
