class AddNonStageFieldToStage < ActiveRecord::Migration
  def change
    add_column :stages, :non_stage, :boolean, default: false
  end
end
