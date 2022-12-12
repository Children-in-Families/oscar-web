class IndexForeignKeysInEnterNgos < ActiveRecord::Migration[5.2]
  def change
    add_index :enter_ngos, :acceptable_id unless index_exists? :enter_ngos, :acceptable_id
  end
end
