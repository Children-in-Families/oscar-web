class Problem < ActiveRecord::Base
  after_commit :flush_cache

  has_paper_trail

  has_many :government_form_problems, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_problems

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'Problem', id]) { find(id) }
  end

  def self.cached_order_created_at
    Rails.cache.fetch([Apartment::Tenant.current, 'Problem', 'cached_order_created_at']) { order(:created_at).to_a }
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Problem', id])
    Rails.cache.delete([Apartment::Tenant.current, 'Problem', 'cached_order_created_at']) if created_at_changed?
  end

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, id]) { find(id) }
  end

  def self.cached_order_created_at
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, 'cached_order_created_at']) { order(:created_at).to_a }
  end
end
