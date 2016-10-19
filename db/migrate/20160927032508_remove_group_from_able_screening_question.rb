class RemoveGroupFromAbleScreeningQuestion < ActiveRecord::Migration
  def change
    remove_column :able_screening_questions, :group, :string
  end
end
