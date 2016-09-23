class Attachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :able_screening_question
end
