class RemoveForeignKeyConstrainOnExitNgos < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL.squish
      ALTER TABLE exit_ngos
      DROP CONSTRAINT IF EXISTS fk_rails_a086c46e5d;
    SQL
  end
end
