class Interviewee < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_interviewees, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_interviewees

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'Interviewee', id]) { find(id) }
  end

  def self.cached_order_created_at
    Rails.cache.fetch([Apartment::Tenant.current, 'Interviewee', 'cached_order_created_at']) { order(:created_at).to_a }
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Interviewee', id])
    Rails.cache.delete([Apartment::Tenant.current, 'Interviewee', 'cached_order_created_at'])
  end
end
