class AddDeletedAtToEnterNgo < ActiveRecord::Migration[5.2]
  def change
    add_column :enter_ngos, :deleted_at, :datetime
    add_index :enter_ngos, :deleted_at
  end
end
