class IndexForeignKeysInOauthAccessGrants < ActiveRecord::Migration[5.2]
  def change
    add_index :oauth_access_grants, :application_id unless index_exists? :oauth_access_grants, :application_id
    add_index :oauth_access_grants, :resource_owner_id unless index_exists? :oauth_access_grants, :resource_owner_id
  end
end
