class Tracking < ActiveRecord::Base
  belongs_to :program_stream

  validates :name, :fields, presence: true
  validates :name, uniqueness: true
end
