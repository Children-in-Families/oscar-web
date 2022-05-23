class AddFieldSettingPickupInfo < ActiveRecord::Migration
  NEW_FIELDS = {
    arrival_at: {
      label: 'Arrivate Date/Time',
      group: :pickup_information,
    },
    flight_nb: {
      label: 'Flight Number'
    },
    ratanak_achievement_program_staff_client_ids: {
      label: 'Ratanak Achievement Program Staff',
      group: :pickup_information,
    },
    mosavy_official: {
      label_only: true,
      group: :pickup_information,
      label: 'MoSAVY Official'
    },
    mosavy_official_name: {
      label: 'Name',
      group: :pickup_information,
    },
    mosavy_official_position: {
      label: 'Position',
      group: :pickup_information,
    }
  }

  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    NEW_FIELDS.each do |name, data|
      field_setting = FieldSetting.create!(
        name: name,
        current_label: data[:label],
        label: data[:label],
        klass_name: :client,
        required: false,
        type: data[:type],
        visible: (Apartment::Tenant.current_tenant == 'ratanak'),
        group: data[:group] || :client
      )
    end
  end

  def down
    FieldSetting.where(name: NEW_FIELDS.keys).delete_all
  end
end
