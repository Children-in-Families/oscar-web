class CreateGlobalIdentityOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :global_identity_organizations do |t|
      t.string :global_id
      t.references :organization, index: true, foreign_key: true
      t.integer :client_id, index: true

      t.timestamps null: false
    end
    add_foreign_key :global_identity_organizations, "public.global_identities", column: :global_id, primary_key: :ulid
    add_index :global_identity_organizations, :global_id
  end
end
