class RemoveForeignKeyConstrainOnClientEnrollments < ActiveRecord::Migration
  def up
    execute <<-SQL.squish
      ALTER TABLE client_enrollments
      DROP CONSTRAINT IF EXISTS fk_rails_304843a19b;

      ALTER TABLE client_enrollments
      DROP CONSTRAINT IF EXISTS fk_rails_f4030e09bc;
    SQL
  end
end
