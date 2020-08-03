class CreateGlobalServices < ActiveRecord::Migration
  def change
    disable_extension 'uuid-ossp'
    enable_extension 'uuid-ossp'
    create_table :global_services, {
        :id           => false,
        :primary_key  => :uuid,
        force: :cascade
      } do |t|
        t.uuid :uuid, index: { unique: true }, default: "gen_random_uuid()"
      end
    reversible do |dir|
      dir.up do
        63.times.each{|_| GlobalService.create! } if GlobalService.count == 0
      end
    end
  end
end
