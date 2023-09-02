module HashDeepTraverse
  def deep_traverse(&block)
    stack = self.map{ |k,v| [ [k], v ] }
    while not stack.empty?
      key, value = stack.pop
      yield(key, value)
      if value.is_a? Hash
        value.each{ |k,v| stack.push [ key.dup << k, v ] }
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

module I18n::Backend::Custom
  class ReloadChecker
    @@last_reload_at = nil

    def self.last_reload_at
      @@last_reload_at
    end

    def self.update_last_reload_at
      @@last_reload_at = Time.current
    end
  end

  def load_translations(*filenames)
    filenames = I18n.load_path if filenames.empty?
    filenames.flatten.each { |filename| load_file(filename) }
    if Apartment::Tenant.current != 'public'
      if Organization.cache_table_exists? 'settings'
        nepal_commune_mapping if Setting.cache_first&.country_name == 'nepal'
      end
      load_custom_labels if Organization.cache_table_exists? 'field_settings'
    end

    ReloadChecker.update_last_reload_at
  end

  def load_custom_labels
    FieldSetting.cache_all.each do |field_setting|
      data = translations[I18n.locale]
      data.extend(HashDeepTraverse)
      next if field_setting.current_label.blank?
      next if data.blank?

      paths = data.full_paths(field_setting.name)
      next if paths.blank?

      paths.each do |path|
        next if path.count > 1 && !field_setting.possible_key_match?(path)
        data = translations[I18n.locale]

        # pp path

        path.each do |k|
          # next if data.nil?
          if k == path.last
            # pp '=========================='
            # pp data[k]
            # pp '=========================='
            data[k] = field_setting&.label.presence || field_setting.current_label
          else
            data = data[k]
          end
        end
      end
    end
  end

  def nepal_commune_mapping
    commune_fields = %w[chief_commune_name concern_commune_id commune initial_commune commune_id commune_en commune_kh concern_district_id district district_en district_kh current_province_en].freeze
    commune_fields.each do |locale_key|
      data = translations[I18n.locale]
      data.extend(HashDeepTraverse)

      next if data.blank?
      paths = data.full_paths(locale_key)
      next if paths.blank?
      paths.each do |path|
        next unless path.include?(locale_key.to_sym)
        data = translations[I18n.locale]
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
            data = data[k]
          end
        end
      end
    end
  end
  alias_method :override_translation, :load_custom_labels
end

I18n::Backend::Simple.send(:include, I18n::Backend::Custom)
