class RemoveGroupFromAbleScreeningQuestion < ActiveRecord::Migration[5.2]
  def change
    remove_column :able_screening_questions, :group, :string
  end
end
