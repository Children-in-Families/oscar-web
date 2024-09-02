# frozen_string_literal: true

module CaseNotes
  class CustomFieldProperty < ::ActiveRecord::Base
    belongs_to :case_note
    belongs_to :custom_field, class_name: 'CaseNotes::CustomField'

    has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy
    validates :case_note, presence: true
    validates :custom_field, presence: true

    accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? && attributes['file'].blank? }

    def get_form_builder_attachment(value)
      form_builder_attachments.find_by(name: value)
    end
  end
end
