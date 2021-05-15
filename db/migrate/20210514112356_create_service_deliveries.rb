class CreateServiceDeliveries < ActiveRecord::Migration
  def change
    create_table :service_deliveries do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
