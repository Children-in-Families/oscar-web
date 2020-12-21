class UpdateData < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current == 'shared'

    FieldSetting.where(name: :client_school_information).delete_all

    if Apartment::Tenant.current == 'brc'
      FieldSetting.where(name: [:school_name, :school_grade, :main_school_contact, :education_background]).update_all(visible: false)
    end
  end
end
