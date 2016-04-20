class CaseSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :carer_names, :carer_address, :carer_phone_number, :case_type,
             :placement_date, :initial_assessment_date, :family, :created_at, :updated_at

  def family
    object.family.as_json(only: [:name, :address, :caregiver_information]) if object.family
  end
end
