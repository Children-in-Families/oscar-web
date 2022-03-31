class Agency < ActiveRecord::Base
  has_many :agency_clients
  has_many :clients, through: :agency_clients
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  after_commit :flush_cache

  def self.name_like(values = [])
    where('name iLIKE ANY ( array[?] )', values)
  end

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'Agency', id]) { find(id) }
  end

  def self.cached_order_name
    Rails.cache.fetch([Apartment::Tenant.current, 'Agency', 'cached_order_name']) { order(:name).to_a }
  end

  def self.cache_agency_options
    Agency.cached_order_name.map { |s| { s.id.to_s => s.name } }
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Agency', id])
    Rails.cache.delete([Apartment::Tenant.current, 'Agency', 'cached_order_name'])
  end
end
