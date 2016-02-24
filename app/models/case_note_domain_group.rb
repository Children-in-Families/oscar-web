class CaseNoteDomainGroup < ActiveRecord::Base
  belongs_to :case_note
  belongs_to :domain_group

  has_many :tasks
end
