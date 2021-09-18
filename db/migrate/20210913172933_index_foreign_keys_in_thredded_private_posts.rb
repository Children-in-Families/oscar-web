class IndexForeignKeysInThreddedPrivatePosts < ActiveRecord::Migration
  def change
    add_index :thredded_private_posts, :postable_id
    add_index :thredded_private_posts, :user_id
  end
end
