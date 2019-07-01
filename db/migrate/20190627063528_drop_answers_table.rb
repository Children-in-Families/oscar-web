class DropAnswersTable < ActiveRecord::Migration
  def up
    drop_table :answers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
