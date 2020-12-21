class DropAnswersTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :answers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
