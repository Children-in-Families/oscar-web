class CreateProblem < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :name, default: ''
      t.timestamps
    end
  end
end
