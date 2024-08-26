# frozen_string_literal: true

module CaseNotes
  class CustomFieldProperty < ::ActiveRecord::Base
    include NestedAttributesConcern

    belongs_to :case_note
    belongs_to :custom_field, class_name: 'CaseNotes::CustomField'

    validates :case_note, presence: true
    validates :custom_field, presence: true
  end
end
