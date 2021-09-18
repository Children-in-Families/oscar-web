class IndexForeignKeysInSettings < ActiveRecord::Migration
  def change
    add_index :settings, :screening_assessment_form_id
  end
end
