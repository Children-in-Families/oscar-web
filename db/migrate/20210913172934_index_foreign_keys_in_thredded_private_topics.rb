class IndexForeignKeysInThreddedPrivateTopics < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_private_topics, :last_user_id
    add_index :thredded_private_topics, :user_id
  end
end
