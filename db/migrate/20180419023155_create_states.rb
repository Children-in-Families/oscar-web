class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
