class AddOriginIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :origin_id, :string
  end
end
