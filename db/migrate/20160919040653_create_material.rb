class CreateMaterial < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :status, default: ''
      t.timestamps
    end
  end
end
