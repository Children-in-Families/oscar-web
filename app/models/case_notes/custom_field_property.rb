# frozen_string_literal: true

module CaseNotes
  class CustomFieldProperty < ::ActiveRecord::Base
    belongs_to :case_note
    belongs_to :custom_field, class_name: 'CustomField'
  end
end
