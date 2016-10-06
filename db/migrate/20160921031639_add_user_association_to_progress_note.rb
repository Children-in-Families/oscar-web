class AddUserAssociationToProgressNote < ActiveRecord::Migration
  def change
    add_reference :progress_notes, :user, index: true, foreign_key: true
  end
end
