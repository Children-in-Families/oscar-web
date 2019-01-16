class SettingSerializer < ActiveModel::Serializer
  attributes :id, :assessment_frequency, :max_assessment, :max_case_note, :case_note_frequency, :age,
  :custom_assessment, :enable_custom_assessment, :enable_default_assessment, :max_custom_assessment,
  :custom_assessment_frequency, :custom_age, :default_assessment
end
