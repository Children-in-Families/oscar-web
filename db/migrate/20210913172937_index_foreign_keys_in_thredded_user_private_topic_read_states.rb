class IndexForeignKeysInThreddedUserPrivateTopicReadStates < ActiveRecord::Migration
  def change
    add_index :thredded_user_private_topic_read_states, :postable_id
  end
end
