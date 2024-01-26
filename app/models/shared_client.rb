class SharedClient < ActiveRecord::Base
  self.table_name = 'shared.shared_clients'

  has_paper_trail

  belongs_to :birth_province, class_name: 'Province', foreign_key: :birth_province_id

  delegate :name, to: :birth_province, prefix: true, allow_nil: true

  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  after_commit :flush_cache

  def self.cached_shared_client_date_of_birth(slug)
    Rails.cache.fetch([Apartment::Tenant.current, 'SharedClient', 'cached_shared_client_date_of_birth', slug]) {
      find_by(slug: slug)&.date_of_birth
    }
  end

  def self.cached_shared_client_birth_province_name(slug)
    Rails.cache.fetch([Apartment::Tenant.current, 'SharedClient', 'cached_shared_client_birth_province_name', slug]) {
      find_by(slug: slug)&.birth_province_name
    }
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'SharedClient', 'cached_shared_client_date_of_birth'] )
    cached_shared_client_date_of_birth_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_shared_client_date_of_birth/].blank? }
    cached_shared_client_date_of_birth_keys.each { |key| Rails.cache.delete(key) }
    cached_shared_client_birth_province_name_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_shared_client_birth_province_name/].blank? }
    cached_shared_client_birth_province_name_keys.each { |key| Rails.cache.delete(key) }
  end
end
