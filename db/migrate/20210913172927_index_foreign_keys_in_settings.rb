class IndexForeignKeysInSettings < ActiveRecord::Migration[5.2]
  def change
    add_index :settings, :screening_assessment_form_id
  end
end
