class Intervention < ActiveRecord::Base
  validates :action, presence: true, uniqueness: true
end
