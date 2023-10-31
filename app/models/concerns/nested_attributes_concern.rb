module NestedAttributesConcern
  extend ActiveSupport::Concern
  included do
    has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy
    accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? && attributes['file'].blank? }
  end

  class_methods do
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end
end
