class AddCompletedFieldToProgramStream < ActiveRecord::Migration
  def change
    add_column  :program_streams, :completed, :boolean, default: false
  end
end
