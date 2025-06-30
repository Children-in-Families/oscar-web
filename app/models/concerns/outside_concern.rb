module OutsideConcern
  extend ActiveSupport::Concern

  included do
    validates :outside, inclusion: { in: [true, false] }

    after_initialize :mark_client_as_outside
    after_create :mark_client_as_outside
  end

  class_methods do; end

  def outside=(value)
    if Organization.current.country == 'international'
      write_attribute(:outside, true)
    else
      write_attribute(:outside, value)
    end
  end

  def mark_client_as_outside
    if Organization.current&.country == 'International'
      self.outside = true
    else
      self.outside = false
    end
  end
end
