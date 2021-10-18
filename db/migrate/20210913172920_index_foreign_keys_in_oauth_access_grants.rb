class IndexForeignKeysInOauthAccessGrants < ActiveRecord::Migration
  def change
    add_index :oauth_access_grants, :application_id
    add_index :oauth_access_grants, :resource_owner_id
  end
end
