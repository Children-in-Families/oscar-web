class CreateEnterNgoUser < ActiveRecord::Migration[5.2]
  def change
    create_table :enter_ngo_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :enter_ngo, index: true, foreign_key: true
    end
  end
end
