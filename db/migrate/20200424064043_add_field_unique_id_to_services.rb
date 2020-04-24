class AddFieldUniqueIdToServices < ActiveRecord::Migration
  def change
    disable_extension 'uuid-ossp'
    enable_extension 'uuid-ossp'
    add_column :services, :uuid, :uuid, default: "uuid_generate_v4()"
  end
end
