class AddFieldsToProgramStream < ActiveRecord::Migration[5.2]
  def change
    add_column :program_streams, :frequency, :string, default: ''
    add_column :program_streams, :time_of_frequency, :integer, default: 0
  end
end
