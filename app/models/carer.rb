class Carer < ApplicationRecord
  belongs_to :province, optional: true
  belongs_to :district, optional: true
  belongs_to :commune, optional: true
  belongs_to :village, optional: true
  belongs_to :state, optional: true
  belongs_to :subdistrict, optional: true
  belongs_to :township, optional: true
  has_many :clients, dependent: :restrict_with_error

  CLIENT_RELATIONSHIPS = ['Parent', 'Grandparent', 'Aunt / Uncle', 'Sibling', 'Cousin', 'Family Friend', 'Foster Carer', 'Temporary Carer', 'RCI Carer', 'Adopted Parent', 'Other'].freeze
end
