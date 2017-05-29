class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :trackings, dependent: :destroy
  has_one :exit_program, dependent: :destroy
end
