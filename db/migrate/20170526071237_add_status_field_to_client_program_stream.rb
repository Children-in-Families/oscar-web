class AddStatusFieldToClientProgramStream < ActiveRecord::Migration
  def change
    add_column :client_program_streams, :status, :string, default: 'Active'
  end
end
