class AddChildsafeAgentToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :childsafe_agent, :boolean
  end
end
