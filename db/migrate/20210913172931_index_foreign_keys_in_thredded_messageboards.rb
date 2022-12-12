class IndexForeignKeysInThreddedMessageboards < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_messageboards, :last_topic_id unless index_exists? :thredded_messageboards, :last_topic_id
  end
end
