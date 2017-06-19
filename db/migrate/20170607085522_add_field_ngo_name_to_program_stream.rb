class AddFieldNgoNameToProgramStream < ActiveRecord::Migration
  def change
    add_column :program_streams, :ngo_name, :string, default: ''
  end
end
