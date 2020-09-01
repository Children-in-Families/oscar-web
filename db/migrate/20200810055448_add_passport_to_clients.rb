class AddPassportToClients < ActiveRecord::Migration
  FIELDS = [
    :national_id_number,
    :passport_number
  ] 

  def change
    add_column :clients, :national_id_number, :string
    add_column :clients, :passport_number, :string


    reversible do |dir|
      dir.up do
        if Apartment::Tenant.current_tenant != 'shared'
          FIELDS.each do |name|
            field_setting = FieldSetting.create!(
              name: name,
              current_label: I18n.t("clients.form.#{name}"),
              klass_name: :client,
              visible: Apartment::Tenant.current_tenant == 'ratanak',
              group: :client
            )
          end
        end
      end

      dir.down do
        FieldSetting.where(name: FIELDS, klass_name: :client).delete_all
      end
    end
  end
end