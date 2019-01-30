class AddEnableGovLogInAndEnableResearchLogInToUser < ActiveRecord::Migration
  def change
    add_column :users, :enable_gov_log_in, :boolean, default: false
    add_column :users, :enable_research_log_in, :boolean, default: false
  end
end
