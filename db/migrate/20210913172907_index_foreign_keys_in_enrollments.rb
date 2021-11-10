class IndexForeignKeysInEnrollments < ActiveRecord::Migration
  def change
    add_index :enrollments, :programmable_id
  end
end
