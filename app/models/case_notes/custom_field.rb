# frozen_string_literal: true

module CaseNotes
  class CustomField < ::ActiveRecord::Base
    validates :fields, presence: true
    has_many :custom_field_properties, dependent: :restrict_with_error
  end
end
