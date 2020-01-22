class ClientNecessity < ActiveRecord::Base
  belongs_to :client
  belongs_to :necessity
end
