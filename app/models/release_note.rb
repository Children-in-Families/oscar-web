class ReleaseNote < ActiveRecord::Base
  scope :published, -> { where(published: true) }
end
