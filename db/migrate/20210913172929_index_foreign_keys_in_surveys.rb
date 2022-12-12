class IndexForeignKeysInSurveys < ActiveRecord::Migration[5.2]
  def change
    add_index :surveys, :user_id unless index_exists? :surveys, :user_id
  end
end
