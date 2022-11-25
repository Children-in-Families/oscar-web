class RemoveForeignKeyConstrainOnEnterNgos < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL.squish
      ALTER TABLE enter_ngos
      DROP CONSTRAINT IF EXISTS fk_rails_544fb35633;
    SQL
  end
end
