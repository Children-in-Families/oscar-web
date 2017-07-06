class AddRuleDefaultValueToProgramStream < ActiveRecord::Migration
  def up
    add_column :program_streams, :rules, :jsonb, default: {}
  end

  def down
    remove_column :program_streams, :rules, :jsonb
  end
end
