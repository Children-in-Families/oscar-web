 class PaperTrail::VersionDecorator < Draper::Decorator
  delegate_all

  # def association_changed
  #   item_associations = item.present? ? track_associations : []
  #   @current = reify(has_many: true, belongs_to: true)
  #   @previous = previous.reify(has_many: true, belongs_to: true) if previous.present?
  #   if @current.present? and @previous.present?
  #     contents = item_associations.map do |association|
  #       h.safe_join([current_associations(association), previous_associations(association)]) if @current.send(association) != @previous.send(association)
  #     end
  #     h.safe_join(contents)
  #   end
  # end

  # def object_info
  #   object.object
  # end

  def whodunnit
    User.find(object.whodunnit).name
  end

  def event
    object.event == 'destroy' ? 'delete' : object.event
  end

  # private

  # def track_associations
  #   item.class.methods.include?(:track_associations) ? item.class.track_associations : item.class.reflect_on_all_associations.map(&:name)
  # end

  # def current_associations(association)
  #   content = @current.send(association).to_json
  #   h.content_tag(:p, "current: #{content}")
  # end

  # def previous_associations(association)
  #   content = @previous.send(association).to_json
  #   h.content_tag(:p, "previous: #{content}")
  # end
end
