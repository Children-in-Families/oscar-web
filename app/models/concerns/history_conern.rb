module HistoryConern
  extend ActiveSupport::Concern
  included do
  end

  class_methods do
    def format_property(attributes)
      mappings = {}
      attributes['properties'].each do |k, v|
        mappings[k] = k.gsub(/(\s|[.])/, '_')
      end
      attributes['properties'].map {|k, v| [mappings[k].downcase, v] }.to_h
    end
  end

  def instance_method
  end
end
