class CustomData < ActiveRecord::Base
  belongs_to :client
  validates :fields, presence: true
end
