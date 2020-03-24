class Carer < ActiveRecord::Base
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  has_many :clients, dependent: :restrict_with_error

  CLIENT_RELATIONSHIPS = ['Parent', 'Grandparent', 'Aunt / Uncle', 'Sibling', 'Cousin', 'Family Friend', 'Foster Carer', 'Temporary Carer', 'RCI Carer', 'Adopted Parent', 'Other'].freeze
end
