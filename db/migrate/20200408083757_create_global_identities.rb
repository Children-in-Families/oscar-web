class CreateGlobalIdentities < ActiveRecord::Migration
  def change
    create_table :global_identities do |t|
      t.binary :ulid, limit: 16
    end
  end
end
