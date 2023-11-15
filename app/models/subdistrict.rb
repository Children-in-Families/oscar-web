class Subdistrict < ActiveRecord::Base
  include AddressConcern

  belongs_to :district, touch: true
  has_many :clients, dependent: :restrict_with_error
  has_many :referees, dependent: :restrict_with_error
  has_many :carers, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :communities, dependent: :restrict_with_error

  validates :district, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:district_id] }

  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, self.name, id]) { find(id) }
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, id])
  end
end
