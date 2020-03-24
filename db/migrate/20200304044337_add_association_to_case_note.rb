class AddAssociationToCaseNote < ActiveRecord::Migration
  def change
    add_reference :case_notes, :custom_assessment_setting, index: true, foreign_key: true
  end
end
