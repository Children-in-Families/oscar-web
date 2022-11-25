class AddFieldSettingData < ActiveRecord::Migration[5.2]
  NEW_FIELDS = {
    marital_status: {
      label: 'Marital Status'
    },
    nationality: {
      label: 'Nationality'
    },
    ethnicity: {
      label: 'Ethnicity'
    },
    location_of_concern: {
      label: 'Destination country'
    },
    type_of_trafficking: {
      label: 'Type of Trafficking'
    },
    education_background: {
      label: 'Education Background',
      group: :school_information
    },
    department: {
      label: 'Ratanak Team'
    }
  }

  HIDDEN_FIELDS = {
    school_name: {
      group: :school_information,
      current_label: 'School Name'
    },
    school_grade: {
      group: :school_information,
      current_label: 'School Grade'
    },
    main_school_contact: {
      group: :school_information,
      current_label: 'Main School Contact'
    }
  }

  RENAME_FIELDS = {
    followed_up_by_id: {
      new_label: 'Initial Meeting by',
      current_label: 'First Follow Up by'
    },
    follow_up_date: {
      new_label: 'Date of Initial Meeting',
      current_label: 'Date of First Follow Up'
    },
    name: {
      current_label: 'Name',
      group: :carer,
      klass_name: :carer,
      new_label: 'Parents Name'
    },
    phone: {
      current_label: 'Carer Phone Number',
      group: :carer,
      klass_name: :carer,
      new_label: 'Parents Phone Number'
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
        visible: (Apartment::Tenant.current_tenant == 'ratanak'),
        group: data[:group] || :client
      )
    end

    HIDDEN_FIELDS.each do |name, data|
      field_setting = FieldSetting.create!(
        name: name,
        klass_name: :client,
        required: false,
        visible: (Apartment::Tenant.current_tenant != 'ratanak'),
        group: data[:group] || :client,
        current_label: data[:current_label]
      )
    end

    RENAME_FIELDS.each do |name, data|
      field_setting = FieldSetting.create!(
        name: name,
        klass_name: data[:klass_name].presence || :client,
        label: (Apartment::Tenant.current_tenant == 'ratanak' ? data[:new_label] : nil),
        required: false,
        visible: true,
        group: data[:group].presence || :client,
        current_label: data[:current_label]
      )
    end
  end

  def down
    FieldSetting.where(name: NEW_FIELDS.keys).delete_all
    FieldSetting.where(name: RENAME_FIELDS.keys).delete_all
    FieldSetting.where(name: HIDDEN_FIELDS.keys).delete_all
  end
end
