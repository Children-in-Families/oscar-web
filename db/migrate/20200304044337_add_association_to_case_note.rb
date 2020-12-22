class AddAssociationToCaseNote < ActiveRecord::Migration[5.2]
  def change
    add_reference :case_notes, :custom_assessment_setting, index: true, foreign_key: true
  end
end
