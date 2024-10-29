# frozen_string_literal: true

module CaseNotes
  class CustomField < ::ActiveRecord::Base
    self.table_name = 'case_notes_custom_fields'

    has_many :custom_field_properties, dependent: :restrict_with_error

    def data_fields
      fields.reject { |field| field['type'] == 'separateLine' }
    end
  end
end
