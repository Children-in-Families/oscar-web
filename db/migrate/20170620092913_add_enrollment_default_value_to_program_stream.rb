class AddEnrollmentDefaultValueToProgramStream < ActiveRecord::Migration
  def change
    change_column :program_streams, :enrollment, :jsonb, default: {}
  end
end
