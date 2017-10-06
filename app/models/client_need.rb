class ClientNeed < ActiveRecord::Base
  belongs_to :client
  belongs_to :need
end
