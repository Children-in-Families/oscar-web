class CreateSurvey < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.references :client, index: true, foreign_key: true
      t.integer :user_id
      t.integer :listening_score
      t.integer :problem_solving_score
      t.integer :getting_in_touch_score
      t.integer :trust_score
      t.integer :difficulty_help_score
      t.integer :support_score
      t.integer :family_need_score
      t.integer :care_score

      t.timestamps
    end
  end
end
