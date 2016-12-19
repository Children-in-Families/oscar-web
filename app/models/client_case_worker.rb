class ClientCaseWorker < ActiveRecord::Base
  belongs_to :case_worker, class_name: 'User', foreign_key: 'user_id'
  belongs_to :client
end
