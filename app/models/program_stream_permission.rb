class ProgramStreamPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :program_stream
end
