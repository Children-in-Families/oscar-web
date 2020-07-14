class AddCaseNotesNoteLabel < ActiveRecord::Migration
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FieldSetting.create!(
      name: :note,
      current_label: 'Note',
      label: (Apartment::Tenant.current_tenant == 'ratanak' ? 'Progress notes and next steps' : nil),
      klass_name: :case_note,
      required: true,
      visible: true,
      group: :case_note
    )
  end

  def down
    FieldSetting.where(name: :note, klass_name: :case_note).delete_all
  end
end
