class IndexForeignKeysInThreddedPostModerationRecords < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_post_moderation_records, :moderator_id
    add_index :thredded_post_moderation_records, :post_id
    add_index :thredded_post_moderation_records, :post_user_id
  end
end
