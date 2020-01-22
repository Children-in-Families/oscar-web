class ClientProtectionConcern < ActiveRecord::Base
  belongs_to :client
  belongs_to :protection_concern
end
