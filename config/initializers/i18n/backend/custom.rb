module HashDeepTraverse
  def deep_traverse(&block)
    stack = self.map { |k, v| [[k], v] }
    while not stack.empty?
      key, value = stack.pop
      yield(key, value)
      if value.is_a? Hash
        value.each { |k, v| stack.push [key.dup << k, v] }
      end
    end
  end

  def full_paths(searched_key)
    paths = []

    deep_traverse do |k, v|
      paths << k if k.last.to_s == searched_key.to_s
    end

    paths
  end
end

Hash.prepend(HashDeepTraverse)

module I18n::Backend::Custom
  def last_reload_at
    @custom_translations[Apartment::Tenant.current]['last_reload_at']
  end

  def update_last_reload_at
    @custom_translations[Apartment::Tenant.current] ||= {}
    @custom_translations[Apartment::Tenant.current]['last_reload_at'] = Time.current
  end

  def update_custom_translations(tenant, locale, data)
    @custom_translations[tenant] ||= {}
    @custom_translations[tenant][locale] = data
  end

  def update_custom_translations_by_tenant(tenant, data)
    @custom_translations ||= {}
    @custom_translations[tenant] = data
  end

  def custom_translations(tenant)
    @custom_translations ||= {}
    @custom_translations[tenant]
  end

  def loaded?
    @custom_translations ||= {}
    @custom_translations.dig(Apartment::Tenant.current, I18n.locale).present?
  end

  def deep_merge(hash1, hash2)
    return hash1 if hash2.nil?

    hash1.merge(hash2) do |key, old_val, new_val|
      if old_val.is_a?(Hash) && new_val.is_a?(Hash)
        deep_merge(old_val, new_val)
      else
        new_val
      end
    end
  end

  def load_custom_translations(tenant = Apartment::Tenant.current)
    reload!
    init_translations

    locale = I18n.locale
    Apartment::Tenant.switch(tenant) do
      data = load_custom_labels(locale)
      data = deep_merge(translations, data)
      data = deep_merge(data, nepal_commune_mapping(locale)) if Setting.cache_first&.country_name == 'nepal'

      update_custom_translations(tenant, locale, data)

      update_last_reload_at
    end
  end

  def load_custom_labels(locale)
    copy_translations = translations.dup

    FieldSetting.includes(:translations).by_instances(Apartment::Tenant.current).each do |field_setting|
      data = copy_translations[locale]
      next if field_setting.current_label.blank? || field_setting.name.nil? || data.nil?
      paths = data.full_paths(field_setting.name)
      next if paths.blank?

      paths.each do |path|
        next if path.count > 1 && !field_setting.possible_key_match?(path)
        data = copy_translations[locale]
        path.each do |k|
          # next if data.nil?
          if k == path.last
            data[k] = field_setting&.label.presence || field_setting.current_label
          else
            data = data[k]
          end
        end
      end
    end

    copy_translations[locale]
  end

  def nepal_commune_mapping(locale)
    copy_translations = translations.dup

    commune_fields = %w[chief_commune_name concern_commune_id commune initial_commune commune_id commune_en commune_kh concern_district_id district district_en district_kh current_province_en].freeze
    commune_fields.each do |locale_key|
      data = copy_translations[locale]

      next if data.blank?
      paths = data.full_paths(locale_key)
      next if paths.blank?
      paths.each do |path|
        next unless path.include?(locale_key.to_sym)
        data = copy_translations[locale]

        path.each do |k|
          if k == path.last
            if k =~ /province/
              data[k] = data[k].gsub(/province\s\(.*\)/i, 'Province')
            elsif k =~ /district/
              data[k] = data[k].gsub(/district.*khan/i, 'District')
            else
              data[k] = data[k].gsub(/commune.*sangkat|commune|commune\s\(.*\)/i, 'Municipality')
            end
          else
            data = data[k] if data[k]
          end
        end
      end
    end

    copy_translations[locale]
  end

  protected

  def lookup(locale, key, scope = [], options = EMPTY_HASH)
    # Rails.logger.info "Custom Look up ==================== #{scope} - #{key} - #{Apartment::Tenant.current}"
    custom_lookup(locale, key, scope, options)
  end

  def custom_lookup(locale, key, scope = [], options = EMPTY_HASH)
    keys = I18n.normalize_keys(locale, key, scope, options[:separator])

    keys.unshift(Apartment::Tenant.current).inject(@custom_translations) do |result, _key|
      return nil unless result.is_a?(Hash)
      unless result.has_key?(_key)
        _key = _key.to_s.to_sym
        return nil unless result.has_key?(_key)
      end
      result = result[_key]
      result = resolve_entry(locale, _key, result, Utils.except(options.merge(:scope => nil), :count)) if result.is_a?(Symbol)
      result
    end
  end

  alias_method :override_translation, :load_custom_labels
end

I18n::Backend::Simple.send(:include, I18n::Backend::Custom)
