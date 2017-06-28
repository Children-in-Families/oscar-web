class AddRuleDefaultValueToProgramStream < ActiveRecord::Migration
  def change
    change_column :program_streams, :rules, :jsonb, default: {}
  end
end
