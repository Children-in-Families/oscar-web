class CreateGlobalServices < ActiveRecord::Migration[5.2]
  def change
    disable_extension "uuid-ossp" if extension_enabled?('uuid-ossp')
    enable_extension "uuid-ossp"
    create_table :global_services, {
        :id           => false,
        :primary_key  => :uuid,
        force: :cascade
      } do |t|
        t.uuid :uuid, index: { unique: true }, default: "uuid_generate_v4()"
      end
    reversible do |dir|
      dir.up do
        63.times.each{|_| GlobalService.create! } if GlobalService.count == 0
      end
    end
  end
end
