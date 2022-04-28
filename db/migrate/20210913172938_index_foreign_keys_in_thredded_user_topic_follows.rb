class IndexForeignKeysInThreddedUserTopicFollows < ActiveRecord::Migration
  def change
    add_index :thredded_user_topic_follows, :topic_id
  end
end
