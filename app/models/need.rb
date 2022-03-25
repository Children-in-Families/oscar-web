class Need < ActiveRecord::Base
  after_commit :flush_cache

  has_paper_trail

  has_many :government_form_needs, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_needs

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, name, id]) { find(id) }
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, id])
  end
end
