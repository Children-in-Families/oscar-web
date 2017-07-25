class CaseSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :carer_names, :carer_address, :carer_phone_number, :support_amount, :support_note, :case_type, :exited, :exit_date, :exit_note, :family, :partner, :province, :created_at, :updated_at, :family_preservation, :status, :placement_date, :initial_assessment_date, :case_length, :case_conference_date, :time_in_care, :exited_from_cif, :current
end
