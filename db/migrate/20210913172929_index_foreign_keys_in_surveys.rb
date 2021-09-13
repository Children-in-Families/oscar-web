class IndexForeignKeysInSurveys < ActiveRecord::Migration
  def change
    add_index :surveys, :user_id
  end
end
