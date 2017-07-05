class AddEnrollmentDefaultValueToProgramStream < ActiveRecord::Migration
  def up
    add_column :program_streams, :enrollment, :jsonb, default: {}
  end

  def down
    remove_column :program_streams, :enrollment, :jsonb
  end
end
