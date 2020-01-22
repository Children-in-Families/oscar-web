class CreateNecessities < ActiveRecord::Migration
  def change
    create_table :necessities do |t|
      t.string :content, default: ''

      t.timestamps null: false
    end
  end
end
