class IndexForeignKeysInThreddedUserMessageboardPreferences < ActiveRecord::Migration
  def change
    add_index :thredded_user_messageboard_preferences, :messageboard_id
  end
end
