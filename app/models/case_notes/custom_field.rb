# frozen_string_literal: true

module CaseNotes
  class CustomField < ::ActiveRecord::Base
    validates :fields, presence: true

    def custom_field_properties
      []
    end
  end
end
