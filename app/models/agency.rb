class Agency < ActiveRecord::Base
  after_commit :flush_cache

  has_many :agency_clients
  has_many :clients, through: :agency_clients
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.name_like(values = [])
    where('name iLIKE ANY ( array[?] )', values)
  end

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, id]) { find(id) }
  end

  def self.cached_order_name
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, 'cached_order_name']) { order(:name).to_a }
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, id])
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'cached_order_name'])
  end
end
