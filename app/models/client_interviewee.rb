class ClientInterviewee < ActiveRecord::Base
  belongs_to :client
  belongs_to :interviewee
end
