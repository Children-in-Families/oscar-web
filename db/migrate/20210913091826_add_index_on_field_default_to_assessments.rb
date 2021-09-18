class AddIndexOnFieldDefaultToAssessments < ActiveRecord::Migration
  def change
    add_index(:assessments, :default, where: "assessments.default = true")
  end
end
