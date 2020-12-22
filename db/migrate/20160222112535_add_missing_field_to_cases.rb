class AddMissingFieldToCases < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :status, :string, default: ''
    add_column :cases, :placement_date, :date
    add_column :cases, :initial_assessment_date, :date
    add_column :cases, :case_length, :float
    add_column :cases, :case_conference_date, :date
    add_column :cases, :time_in_care, :float
  end
end
