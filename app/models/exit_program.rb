class ExitProgram < ActiveRecord::Base
  belongs_to :client_program_stream
  belongs_to :enrollment
end
