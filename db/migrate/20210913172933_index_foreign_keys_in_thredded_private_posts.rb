class IndexForeignKeysInThreddedPrivatePosts < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_private_posts, :postable_id unless index_exists? :thredded_private_posts, :postable_id
    add_index :thredded_private_posts, :user_id unless index_exists? :thredded_private_posts, :user_id
  end
end
