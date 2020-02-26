class CallNecessity < ActiveRecord::Base
  belongs_to :call
  belongs_to :necessity
end
