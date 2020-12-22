class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.string :description
      t.references :able_screening_question, index: true, foreign_key: true
      t.references :client, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
