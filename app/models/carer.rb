class Carer < ActiveRecord::Base
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  has_many :clients

  CLIENT_RELATIONSHIPS = ['Parent', 'Grandparent', 'Aunt / Uncle', 'Sibling', 'Cousin', 'Family Friend', 'Foster Carer', 'Temporary Carer', 'RCI Carer', 'Adopted Parent', 'Other'].freeze
end
