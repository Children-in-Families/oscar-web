class Referee < ActiveRecord::Base
  include CacheAll

  ADDRESS_TYPES = ['Home', 'Business', 'RCI', 'Dormitory', 'Other'].freeze
  FIELDS = %w(id name gender adult anonymous phone email address_type outside province_id district_id commune_id village_id current_address house_number locality outside_address street_number created_at updated_at)
  GENDER_OPTIONS = ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other']

  attr_accessor :existing_referree

  belongs_to :province
  belongs_to :city
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  belongs_to :state
  belongs_to :subdistrict
  belongs_to :township
  has_many :clients, dependent: :restrict_with_error
  has_many :calls, dependent: :restrict_with_error

  validates :name, presence: true

  after_initialize :init_existing_referree

  scope :none_anonymous, -> { where(anonymous: false) }

  def self.cache_none_anonymous
    Rails.cache.fetch([Apartment::Tenant.current, self.name, 'non_anonymous']) { none_anonymous.to_a }
  end

  private

  def init_existing_referree
    @existing_referree = !self.anonymous? && self.persisted?
  end
end
