class UpdateReferences < ActiveRecord::Migration[5.2]
  def change
    remove_reference :case_notes,  :case
    remove_reference :assessments, :case
    remove_reference :tasks,       :case

    add_reference :case_notes,  :client, index: true, foreign_key: true
    add_reference :assessments, :client, index: true, foreign_key: true
  end
end
