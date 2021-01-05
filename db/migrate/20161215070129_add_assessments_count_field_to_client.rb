class AddAssessmentsCountFieldToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :assessments_count, :integer
  end
end
