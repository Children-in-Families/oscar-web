class DomainProgramStream < ActiveRecord::Base
  belongs_to :program_stream
  belongs_to :domain
end
