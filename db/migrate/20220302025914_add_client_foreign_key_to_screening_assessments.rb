class AddClientForeignKeyToScreeningAssessments < ActiveRecord::Migration
  def change
    add_column :screening_assessments, :client_id, :integer
    add_index :screening_assessments, :client_id
  end
end
