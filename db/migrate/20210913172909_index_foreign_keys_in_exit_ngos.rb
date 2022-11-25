class IndexForeignKeysInExitNgos < ActiveRecord::Migration[5.2]
  def change
    add_index :exit_ngos, :rejectable_id
  end
end
