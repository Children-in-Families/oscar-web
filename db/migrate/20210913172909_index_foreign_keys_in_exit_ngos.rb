class IndexForeignKeysInExitNgos < ActiveRecord::Migration
  def change
    add_index :exit_ngos, :rejectable_id
  end
end
