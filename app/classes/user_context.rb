class UserContext
  attr_reader :user, :field_settings

  def initialize(user, field_settings)
    @user = user
    @field_settings   = field_settings
  end
end
