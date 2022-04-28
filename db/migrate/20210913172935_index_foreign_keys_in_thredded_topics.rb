class IndexForeignKeysInThreddedTopics < ActiveRecord::Migration
  def change
    add_index :thredded_topics, :last_user_id
  end
end
