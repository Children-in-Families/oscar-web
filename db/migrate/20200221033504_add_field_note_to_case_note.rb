class AddFieldNoteToCaseNote < ActiveRecord::Migration[5.2]
  def change
    add_column :case_notes, :note, :text, default: ''
  end
end
