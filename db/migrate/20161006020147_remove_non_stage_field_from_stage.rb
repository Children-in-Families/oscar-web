class RemoveNonStageFieldFromStage < ActiveRecord::Migration
  def change
    remove_column :stages, :non_stage, :string
  end
end
