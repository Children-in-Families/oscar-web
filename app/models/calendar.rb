class Calendar < ActiveRecord::Base
  belongs_to :user

  scope :sync_status_false, -> { where(sync_status: false) }
end
