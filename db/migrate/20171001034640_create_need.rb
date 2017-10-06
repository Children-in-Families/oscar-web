class CreateNeed < ActiveRecord::Migration
  def change
    create_table :needs do |t|
      t.string :name, default: ''
      t.timestamps
    end
  end
end
