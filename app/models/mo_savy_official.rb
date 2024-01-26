class MoSavyOfficial < ActiveRecord::Base
  include CacheAll
  
  belongs_to :client
end
