class AddRuleDefaultValueToProgramStream < ActiveRecord::Migration[5.2]
  def up
    change_column :program_streams, :rules, :jsonb, default: {}
  end

  def down
    change_column :program_streams, :rules, :jsonb
  end
end
