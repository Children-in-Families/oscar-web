class IndexForeignKeysInEnrollments < ActiveRecord::Migration[5.2]
  def change
    add_index :enrollments, :programmable_id unless index_exists? :enrollments, :programmable_id
  end
end
