module EntityRetouch
  extend ActiveSupport::Concern

  included do
    after_commit :touch_entity, on: [:create, :update]
  end

  def touch_entity
    programmable&.touch
  end
end
