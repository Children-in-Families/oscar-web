class Carer < ActiveRecord::Base
  belongs_to :province
  belongs_to :city
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  belongs_to :state
  belongs_to :subdistrict
  belongs_to :township
  has_many :clients, dependent: :restrict_with_error

  CLIENT_RELATIONSHIPS = ['Husband', 'Son', 'Daughter', 'Parent', 'Grandparent', 'Grandson', 'Granddaughter', 'Aunt / Uncle', 'Sibling', 'Cousin', 'Family Friend', 'Foster Carer', 'Temporary Carer', 'RCI Carer', 'Adopted Parent', 'Other'].freeze
end
