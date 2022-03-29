class ClientType < ActiveRecord::Base
  has_paper_trail

  has_many :client_type_government_forms, dependent: :restrict_with_error
  has_many :government_forms, through: :client_type_government_forms

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'ClientType', id]) { find(id) }
  end

  def self.cached_order_created_at
    Rails.cache.fetch([Apartment::Tenant.current, 'ClientType', 'cached_order_created_at']) { order(:created_at).to_a }
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'ClientType', id])
    Rails.cache.delete([Apartment::Tenant.current, 'ClientType', 'cached_order_created_at']) if created_at_changed?
  end
end
