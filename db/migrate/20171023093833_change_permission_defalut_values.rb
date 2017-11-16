class ChangePermissionDefalutValues < ActiveRecord::Migration
  def change
    change_column_default :permissions, :case_notes_readable, true
    change_column_default :permissions, :case_notes_editable, true
    change_column_default :permissions, :assessments_readable, true
    change_column_default :permissions, :assessments_editable, true

    change_column_default :custom_field_permissions, :readable, true
    change_column_default :custom_field_permissions, :editable, true

    change_column_default :program_stream_permissions, :readable, true
    change_column_default :program_stream_permissions, :editable, true
  end
end
