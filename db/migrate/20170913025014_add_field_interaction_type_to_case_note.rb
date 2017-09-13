class AddFieldInteractionTypeToCaseNote < ActiveRecord::Migration
  def change
    add_column :case_notes, :interaction_type, :string, default: ''
  end
end
