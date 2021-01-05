class RemoveFieldsFromProgramStream < ActiveRecord::Migration[5.2]
  def change
    remove_column :program_streams, :tracking, :jsonb
    remove_column :program_streams, :frequency, :string
    remove_column :program_streams, :time_of_frequency, :integer
  end
end
