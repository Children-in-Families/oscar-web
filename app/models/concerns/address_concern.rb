module AddressConcern
  extend ActiveSupport::Concern
  included do
    scope :dropdown_list_option, -> { joins(:clients).pluck(:name, :id).uniq.sort.map{|s| { s[1].to_s => s[0] } } }
  end

  class_methods do
  end

  def instance_method
  end
end
