class AddRefereeCarerToClient < ActiveRecord::Migration
  def change
    add_column :clients, :referee_id, :integer
    add_column :clients, :carer_id, :integer
  end
end
