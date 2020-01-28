class Referee < ActiveRecord::Base
  ADDRESS_TYPES    = ['Home', 'Business', 'RCI', 'Dormitory', 'Other'].freeze
  FIELDS = %w(id name gender adult anonymous answered_call called_before phone email address_type outside requested_update province_id district_id commune_id village_id current_address house_number outside_address street_number created_at updated_at)
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  has_many :clients, dependent: :restrict_with_error
  has_many :calls, dependent: :restrict_with_error

  validates :name, presence: true
end
