class IndexForeignKeysInThreddedUserMessageboardPreferences < ActiveRecord::Migration[5.2]
  def change
    add_index :thredded_user_messageboard_preferences, :messageboard_id
  end
end
