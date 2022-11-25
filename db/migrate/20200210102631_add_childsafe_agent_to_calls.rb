class AddChildsafeAgentToCalls < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :childsafe_agent, :boolean
  end
end
