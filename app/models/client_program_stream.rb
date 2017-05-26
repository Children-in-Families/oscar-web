class ClientProgramStream < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :enrollments, dependent: :destroy

  accepts_nested_attributes_for :enrollments
end
