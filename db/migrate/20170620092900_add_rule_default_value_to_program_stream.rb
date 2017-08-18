class AddRuleDefaultValueToProgramStream < ActiveRecord::Migration
  def up
    change_column :program_streams, :rules, :jsonb, default: {}
  end

  def down
    change_column :program_streams, :rules, :jsonb
  end
end
