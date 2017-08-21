class AddEnrollmentDefaultValueToProgramStream < ActiveRecord::Migration
  def up
    change_column :program_streams, :enrollment, :jsonb, default: {}
  end

  def down
    change_column :program_streams, :enrollment, :jsonb
  end
end
