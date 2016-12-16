class AddAssessmentsCountFieldToClient < ActiveRecord::Migration
  def change
    add_column :clients, :assessments_count, :integer
  end
end
