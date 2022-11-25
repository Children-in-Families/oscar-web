class AddIndexOnFieldDefaultToAssessments < ActiveRecord::Migration[5.2]
  def change
    add_index(:assessments, :default, where: "assessments.default = true")
  end
end
