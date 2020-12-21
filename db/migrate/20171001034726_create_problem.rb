class CreateProblem < ActiveRecord::Migration[5.2]
  def change
    create_table :problems do |t|
      t.string :name, default: ''
      t.timestamps
    end
  end
end
