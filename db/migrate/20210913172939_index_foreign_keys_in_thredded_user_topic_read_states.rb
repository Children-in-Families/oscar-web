class IndexForeignKeysInThreddedUserTopicReadStates < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_user_topic_read_states, :postable_id
  end
end
