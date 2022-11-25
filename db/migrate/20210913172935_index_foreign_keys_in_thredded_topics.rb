class IndexForeignKeysInThreddedTopics < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_topics, :last_user_id
  end
end
