class CallProtectionConcern < ActiveRecord::Base
  belongs_to :call
  belongs_to :protection_concern
end
