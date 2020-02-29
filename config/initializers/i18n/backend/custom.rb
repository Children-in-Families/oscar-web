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
  def load_translations(*filenames)
    filenames = I18n.load_path if filenames.empty?
    filenames.flatten.each { |filename| load_file(filename) }
    load_custom_labels
  end

  def load_custom_labels
    FieldSetting.includes(:translations).find_each do |field_setting|
      data = translations[I18n.locale]
      data.extend(HashDeepTraverse)

      return if field_setting.label.blank?

      paths = data.full_paths(field_setting.name)
      next if paths.blank?

      paths.each do |path|
        next if path.count > 1 && path.all?{ |k| k =! field_setting.group && k.to_s.pluralize != field_setting.group.pluralize }
        data = translations[I18n.locale]

        pp path

        path.each do |k|
          if k == path.last
            # pp '=========================='
            # pp data[k]
            # pp '=========================='
            data[k] = field_setting.label
          else
            data = data[k]
          end
        end
      end
    end
  end

  alias_method :reload_custom_labels, :load_custom_labels
end

I18n::Backend::Simple.send(:include, I18n::Backend::Custom)
