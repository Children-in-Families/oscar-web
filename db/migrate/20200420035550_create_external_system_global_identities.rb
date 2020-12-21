class CreateExternalSystemGlobalIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :external_system_global_identities do |t|
      t.references :external_system, index: true, foreign_key: true
      t.string :global_id
      t.string :external_id
      t.string :client_slug
      t.string :organization_name

      t.timestamps null: false
    end
    add_foreign_key :external_system_global_identities, "public.global_identities", column: :global_id, primary_key: :ulid
    add_index :external_system_global_identities, :global_id
  end
end
