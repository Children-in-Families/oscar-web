class IndexForeignKeysInThreddedUserTopicFollows < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_user_topic_follows, :topic_id
  end
end
