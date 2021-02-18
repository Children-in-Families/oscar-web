module HistoryConcern
  extend ActiveSupport::Concern
  included do
  end

  class_methods do
    def format_property(attributes)
      mappings = {}
      attributes['properties'].each do |k, _|
        mappings[k] = k.gsub(/(\s|[.])/, '_')
      end
      attributes['properties'].map { |k, v| [mappings[k].downcase, v] }.to_h
    end
  end
end
