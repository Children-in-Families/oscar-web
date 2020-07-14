class AddFieldUniqueIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :uuid, :uuid

    reversible do |dir|
      dir.up do
        add_foreign_key :services, "public.global_services", column: :uuid, primary_key: :uuid
        add_index :services, :uuid
        if Service.count == GlobalService.count
          global_service_services = [GlobalService.order(:uuid), Service.order(:id)].transpose
          global_service_services.each do |gb_service, service|
            service.update_attributes(uuid: gb_service.uuid)
          end
        end
      end

      dir.down do
        remove_foreign_key :services, "public.global_services", column: :uuid, primary_key: :uuid if foreign_keys(:services).map(&:column).include?("uuid")
        remove_index :services, :uuid
      end
    end
  end
end
