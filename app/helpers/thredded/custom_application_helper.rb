module Thredded
  module CustomApplicationHelper

    def topic_read_state(topic)
      topic.states.map { |s| "thredded--topic-#{s}" }
    end
  end
end
