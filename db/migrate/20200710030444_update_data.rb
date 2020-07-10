class UpdateData < ActiveRecord::Migration
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FieldSetting.where(name: :client_school_information).delete_all

    if Apartment::Tenant.current_tenant == 'brc'
      FieldSetting.where(name: [:school_name, :school_grade, :main_school_contact, :education_background]).update_all(visible: false)
    end
  end
end
