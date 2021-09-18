class IndexForeignKeysInEnterNgos < ActiveRecord::Migration
  def change
    add_index :enter_ngos, :acceptable_id
  end
end
