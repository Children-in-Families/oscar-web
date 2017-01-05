module Thredded
  class TopicPolicy
    class Scope
      def initialize(user, scope)
        @user  = user
        @scope = scope
      end

      def resolve
        @scope.moderation_state_visible_to_user(@user)
      end
    end

    def initialize(user, topic)
      @user                = user
      @topic               = topic
      @messageboard_policy = Thredded::MessageboardPolicy.new(user, topic.messageboard)
    end

    def create?
      @messageboard_policy.post?
    end

    def read?
      @messageboard_policy.read? && @topic.moderation_state_visible_to_user?(@user)
    end

    def update?
      @user.thredded_admin? || @topic.user_id == @user.id || moderate?
    end

    def destroy?
      @user.thredded_admin? || @user.any_manager?
    end

    def moderate?
      @messageboard_policy.moderate?
    end
  end
end
