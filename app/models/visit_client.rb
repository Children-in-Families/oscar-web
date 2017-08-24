class VisitClient < ActiveRecord::Base
  belongs_to :user

  def self.initial_visit_client(user)
    create(user: user)
  end
end
