class GovernmentFormInterviewee < ActiveRecord::Base
  belongs_to :government_form
  belongs_to :interviewee
end
