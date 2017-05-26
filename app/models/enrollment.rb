class Enrollment < ActiveRecord::Base
  belongs_to :client_program_stream
  
  has_one :exit_program

  has_many :trackings

end
