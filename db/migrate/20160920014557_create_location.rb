class CreateLocation < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name, default: ''
      t.timestamps
    end
  end
end
