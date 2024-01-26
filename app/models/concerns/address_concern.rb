module AddressConcern
  extend ActiveSupport::Concern
  included do
    after_commit :flush_cache
    scope :dropdown_list_option, -> { joins(:clients).pluck(:name, :id).uniq.sort.map { |s| { s[1].to_s => s[0] } } }
  end

  class_methods do
    def cached_dropdown_list_option
      Rails.cache.fetch([Apartment::Tenant.current, self.name, 'dropdown_list_option']) { self.dropdown_list_option }
    end
  end

  def instance_method
    private

    def flush_cache
      Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'dropdown_list_option'])
    end
  end
end
