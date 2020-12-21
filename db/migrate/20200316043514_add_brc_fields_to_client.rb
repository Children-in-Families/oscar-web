class AddBrcFieldsToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :difficulties, :text
    add_column :clients, :household_members, :text
    add_column :clients, :hosting_number, :text
    add_column :clients, :interview_locations, :text
    add_column :clients, :bic_others, :text
  end
end
