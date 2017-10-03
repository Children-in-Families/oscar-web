class ClientClientType < ActiveRecord::Base
  belongs_to :client
  belongs_to :client_type
end
