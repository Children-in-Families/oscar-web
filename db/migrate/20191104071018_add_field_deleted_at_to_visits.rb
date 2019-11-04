class AddFieldDeletedAtToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :deleted_at, :datetime
  end
end
