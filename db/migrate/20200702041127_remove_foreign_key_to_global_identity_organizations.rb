class RemoveForeignKeyToGlobalIdentityOrganizations < ActiveRecord::Migration
  def up
    remove_foreign_key :global_identity_organizations, column: :global_id if foreign_keys(:global_identity_organizations).map(&:column).include?("global_id")
  end

  def down
    add_foreign_key :global_identity_organizations, "public.global_identities", column: :global_id, primary_key: :ulid if !foreign_keys(:global_identity_organizations).map(&:column).include?("global_id")
  end
end
