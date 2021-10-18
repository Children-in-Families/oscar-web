class IndexForeignKeysInThreddedMessageboards < ActiveRecord::Migration
  def change
    add_index :thredded_messageboards, :last_topic_id
  end
end
