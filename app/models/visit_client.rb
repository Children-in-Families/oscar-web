class VisitClient < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, with_deleted: true

  def self.initial_visit_client(user)
    create(user: user)
  end
end
