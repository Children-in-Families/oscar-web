class AddQuestionTypeToAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :question_type, :string, default: ''
  end
end
