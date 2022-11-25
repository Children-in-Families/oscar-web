class CreateAchievementProgramStaffClients < ActiveRecord::Migration[5.2]
  def change
    create_table :achievement_program_staff_clients do |t|
      t.references :client, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
