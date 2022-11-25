class IndexForeignKeysInOauthAccessTokens < ActiveRecord::Migration[5.2]
  def change
    add_index :oauth_access_tokens, :application_id
  end
end
