class AddFieldInteractionTypeToCaseNote < ActiveRecord::Migration[5.2]
  def change
    add_column :case_notes, :interaction_type, :string, default: ''
  end
end
