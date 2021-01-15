class AddEntityTypeToProgramStream < ActiveRecord::Migration
  def up
    add_column :program_streams, :entity_type, :string, default: ''

    ProgramStream.where(entity_type: '').each do |program|
      program.entity_type = 'Client'
      program.save(validate: false)
    end
  end

  def down
    remove_column :program_streams, :entity_type, :string
  end
end
