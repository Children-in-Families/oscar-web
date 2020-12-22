class CreateQuestionGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :question_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
