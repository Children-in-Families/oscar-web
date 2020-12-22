class CreateAbleScreeningQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :able_screening_questions do |t|
      t.string :question
      t.string :mode
      t.string :group
      t.references :stage, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
