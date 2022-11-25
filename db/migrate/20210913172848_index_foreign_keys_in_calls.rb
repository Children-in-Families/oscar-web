class IndexForeignKeysInCalls < ActiveRecord::Migration[5.2]
  def change
    add_index :calls, :phone_call_id
    add_index :calls, :receiving_staff_id
  end
end
