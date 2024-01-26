module CacheAll
  extend ActiveSupport::Concern

  included do
    after_commit :flush_cache
  end

  class_methods do
    def cache_all
      Rails.cache.fetch([Apartment::Tenant.current, self.name]) { all.to_a }
    end
  end


  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, self.class.name])
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'non_anonymous'])
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'only_enable_custom_assessment'])
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'case_workers'])
  end
end
