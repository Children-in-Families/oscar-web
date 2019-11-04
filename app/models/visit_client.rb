class VisitClient < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  def self.initial_visit_client(user)
    create(user: user)
  end
end
