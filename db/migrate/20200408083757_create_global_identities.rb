class CreateGlobalIdentities < ActiveRecord::Migration
  def change
    create_table  :global_identities,
      {
        :id           => false,
        :primary_key  => :ulid
      } do |t|
        t.string :ulid, index: { unique: true }
      end
  end
end
