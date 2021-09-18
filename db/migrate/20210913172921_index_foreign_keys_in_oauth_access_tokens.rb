class IndexForeignKeysInOauthAccessTokens < ActiveRecord::Migration
  def change
    add_index :oauth_access_tokens, :application_id
  end
end
