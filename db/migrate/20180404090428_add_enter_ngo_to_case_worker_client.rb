class AddEnterNgoToCaseWorkerClient < ActiveRecord::Migration
  def change
    add_reference :case_worker_clients, :enter_ngo, index: true, foreign_key: true
  end
end
