class RemoveSomeColumnsFromClients < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :difficulties
    remove_column :clients, :household_members
    remove_column :clients, :interview_locations
    remove_column :clients, :hosting_number
    remove_column :clients, :bic_others
  end
end
