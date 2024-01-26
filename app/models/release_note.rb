class ReleaseNote < ActiveRecord::Base
  mount_uploaders :attachments, FileUploader
  scope :published, -> { where(published: true) }
end
