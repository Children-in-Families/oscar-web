class AddProgramExclusiveAndMutualDependenceToProgramStream < ActiveRecord::Migration
  def change
    add_column :program_streams, :program_exclusive, :integer, array: true, default: []
    add_column :program_streams, :mutual_dependence, :integer, array: true, default: []
  end
end
