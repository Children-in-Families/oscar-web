class QuantitativeTypePermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :quantitative_type

  scope :order_by_quantitative_type, -> { joins(:quantitative_type).order('lower(quantitative_types.name)') }
  scope :readable, -> { where(readable: true) }
  scope :editable, -> { where(editable: true) }
end
