class CallProtectionConcern < ApplicationRecord
  belongs_to :call
  belongs_to :protection_concern
end
