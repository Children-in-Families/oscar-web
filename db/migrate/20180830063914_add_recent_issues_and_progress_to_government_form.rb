class AddRecentIssuesAndProgressToGovernmentForm < ActiveRecord::Migration
  def change
    add_column :government_forms, :recent_issues_and_progress, :text, default: ''
  end
end
