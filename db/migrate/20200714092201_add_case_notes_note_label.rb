class AddCaseNotesNoteLabel < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current == 'shared' || FieldSetting.find_by(name: :note, current_label: (Apartment::Tenant.current == 'ratanak' ? 'Progress notes and next steps' : 'Note'), klass_name: :case_note)

    FieldSetting.create!(
      name: :note,
      current_label: (Apartment::Tenant.current == 'ratanak' ? 'Progress notes and next steps' : 'Note'),
      label: (Apartment::Tenant.current == 'ratanak' ? 'Progress notes and next steps' : nil),
      klass_name: :case_note,
      required: true,
      visible: true,
      group: :case_note
    )
  end

  def down
    # FieldSetting.where(name: :note, klass_name: :case_note).delete_all
  end
end
