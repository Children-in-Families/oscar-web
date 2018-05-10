class AddOriginIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :origin_id, :string
    add_column :clients, :referred_from, :string
  end
end
